# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::Findings::CreateFromSecurityFindingService, '#execute' do
  before do
    stub_licensed_features(security_dashboard: true)
    project.add_developer(user)
  end

  let_it_be(:project) { create(:project) }
  let_it_be(:pipeline) { create(:ci_pipeline, :success) }

  let_it_be(:build_sast) { create(:ci_build, :success, name: 'sast', pipeline: pipeline) }
  let_it_be(:artifact_sast) do
    create(:ee_ci_job_artifact, :sast_with_signatures_and_vulnerability_flags,
           job: build_sast)
  end

  let_it_be(:report_sast) { create(:ci_reports_security_report, pipeline: pipeline, type: :sast) }
  let_it_be(:scan_sast) { create(:security_scan, :latest_successful, scan_type: :sast, build: artifact_sast.job) }

  let_it_be(:pipeline_dast) { create(:ci_pipeline) }
  let_it_be(:build_dast) { create(:ci_build, :success, name: 'dast', pipeline: pipeline_dast) }
  let_it_be(:artifact_dast) { create(:ee_ci_job_artifact, :dast_with_evidence, job: build_dast) }
  let_it_be(:report_dast) { create(:ci_reports_security_report, pipeline: pipeline_dast, type: :dast) }
  let_it_be(:scan_dast) { create(:security_scan, :latest_successful, scan_type: :dast, build: artifact_dast.job) }

  let_it_be(:user) { create(:user) }
  let_it_be(:dast_security_findings) { [] }
  let_it_be(:sast_security_findings) { [] }

  before_all do
    sast_content = File.read(artifact_sast.file.path)
    Gitlab::Ci::Parsers::Security::Sast.parse!(sast_content, report_sast)
    report_sast.merge!(report_sast)

    dast_content = File.read(artifact_dast.file.path)
    Gitlab::Ci::Parsers::Security::Dast.parse!(dast_content, report_dast)
    report_dast.merge!(report_dast)

    dast_security_findings.push(*insert_security_findings(report_dast, scan_dast))
    sast_security_findings.push(*insert_security_findings(report_sast, scan_sast))
  end

  let(:security_finding) { sast_security_findings.first }
  let(:security_finding_uuid) { security_finding.uuid }
  let(:params) { { security_finding_uuid: security_finding_uuid } }

  subject { described_class.new(project: project, current_user: user, params: params).execute }

  RSpec.shared_examples 'create vulnerability finding' do
    it 'creates a new vulnerability finding' do
      expect(subject.payload[:vulnerability_finding].uuid).to eq(security_finding_uuid)
      expect(subject.payload[:vulnerability_finding].severity).to eq(security_finding.severity)
      expect(subject.payload[:vulnerability_finding].confidence).to eq(security_finding.confidence)
    end
  end

  context 'when security finding not found' do
    let(:security_finding_uuid) { 'invalid-uuid' }

    it 'returns an error' do
      expect(subject).to be_error
      expect(subject[:message]).to eq('Security Finding not found')
    end
  end

  context 'when there is an existing vulnerability for the security finding' do
    let_it_be(:finding) do
      create(:vulnerabilities_finding, :detected, report_type: :sast, project: project,
             uuid: sast_security_findings.first.uuid)
    end

    let_it_be(:vulnerability) do
      create(:vulnerability, report_type: :sast, project: project,
             findings: [finding])
    end

    it 'creates a new Vulnerability::Finding with the existing vulnerability id' do
      expect(subject.success?).to be_truthy
      expect(subject.payload[:vulnerability_finding].vulnerability_id).to eq(vulnerability.id)
    end
  end

  context 'when there is no vulnerability for the security finding' do
    it 'creates a new Vulnerability::Finding without Vulnerability' do
      expect(subject.success?).to be_truthy
      expect(subject.payload[:vulnerability_finding].vulnerability_id).to be_nil
    end
  end

  context 'when the report finding has signatures' do
    it 'associates the signatures' do
      expect(subject.success?).to be_truthy
      expect(subject.payload[:vulnerability_finding].signatures.size).to eq(2)
    end

    it_behaves_like 'create vulnerability finding'
  end

  context 'when the report finding has evidences' do
    let(:security_finding) { dast_security_findings.first }

    it 'associates the signatures' do
      expect(subject.success?).to be_truthy
      evidence_summary = subject.payload[:vulnerability_finding].finding_evidence.data.dig('summary')
      expect(evidence_summary).to eq('Set-Cookie: JSESSIONID')
    end

    it_behaves_like 'create vulnerability finding'
  end

  context 'when there is no report finding for the security finding' do
    let_it_be(:security_finding) { create(:security_finding, scan: scan_sast) }

    let(:security_finding_uuid) { security_finding.uuid }

    it 'returns an error' do
      expect(subject.success?).to be_falsey
      expect(subject[:message]).to eq('Report Finding not found')
    end
  end

  context 'when sast_fp_reduction feature is available' do
    before do
      stub_licensed_features(sast_fp_reduction: true)
    end

    it_behaves_like 'create vulnerability finding'

    it 'associates the vulnerabilities flags' do
      expect(subject.payload[:vulnerability_finding].vulnerability_flags.first.flag_type).to eq('false_positive')
    end
  end

  def insert_security_findings(report, scan)
    report.findings.map do |finding|
      create(:security_finding,
             severity: finding.severity,
             confidence: finding.confidence,
             uuid: finding.uuid,
             scan: scan)
    end
  end
end
