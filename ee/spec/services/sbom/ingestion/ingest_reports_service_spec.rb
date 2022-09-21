# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sbom::Ingestion::IngestReportsService do
  let_it_be(:pipeline) { create(:ci_pipeline) }
  let_it_be(:reports) { create_list(:ci_reports_sbom_report, 4) }

  let(:wrapper) { instance_double('Gitlab::Ci::Reports::Sbom::Reports') }

  subject(:execute) { described_class.execute(pipeline) }

  before do
    allow(wrapper).to receive(:reports).and_return(reports)
    allow(pipeline).to receive(:sbom_reports).and_return(wrapper)
  end

  describe '#execute' do
    it 'executes IngestReportService for each report' do
      reports.each do |report|
        expect(::Sbom::Ingestion::IngestReportService).to receive(:execute).with(pipeline, report)
      end

      execute
    end
  end
end
