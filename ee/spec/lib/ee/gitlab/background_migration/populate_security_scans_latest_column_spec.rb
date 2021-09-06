# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Gitlab::BackgroundMigration::PopulateSecurityScansLatestColumn do
  let(:migrator) { described_class.new }

  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:pipelines) { table(:ci_pipelines) }
  let(:builds) { table(:ci_builds) }
  let(:artifacts) { table(:ci_job_artifacts) }
  let(:security_scans) { table(:security_scans) }

  let(:namespace) { namespaces.create!(name: 'gitlab', path: 'gitlab-org') }
  let(:project) { projects.create!(namespace_id: namespace.id, name: 'Foo') }
  let(:pipeline)  { pipelines.create!(project_id: project.id, ref: 'master', sha: 'adf43c3a') }

  let(:retried_sast_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_codequality_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:latest_sast_build) { builds.create!(commit_id: pipeline.id, retried: false) }
  let(:retried_dependency_scanning_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_container_scanning_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_dast_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_secret_detection_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_coverage_fuzzing_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_api_fuzzing_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_cluster_image_scanning_build) { builds.create!(commit_id: pipeline.id, retried: true) }

  let!(:retried_sast_scan) { security_scans.create!(project_id: project.id, pipeline_id: pipeline.id, scan_type: 0, build_id: retried_sast_build.id) }
  let!(:latest_sast_scan) { security_scans.create!(project_id: project.id, pipeline_id: pipeline.id, scan_type: 0, build_id: latest_sast_build.id) }
  let!(:retried_dependency_scanning_scan) { security_scans.create!(project_id: project.id, pipeline_id: pipeline.id, scan_type: 0, build_id: retried_dependency_scanning_build.id) }
  let!(:retried_container_scanning_scan) { security_scans.create!(project_id: project.id, pipeline_id: pipeline.id, scan_type: 0, build_id: retried_container_scanning_build.id) }
  let!(:retried_dast_scan) { security_scans.create!(project_id: project.id, pipeline_id: pipeline.id, scan_type: 0, build_id: retried_dast_build.id) }
  let!(:retried_secret_detection_scan) { security_scans.create!(project_id: project.id, pipeline_id: pipeline.id, scan_type: 0, build_id: retried_secret_detection_build.id) }
  let!(:retried_coverage_fuzzing_scan) { security_scans.create!(project_id: project.id, pipeline_id: pipeline.id, scan_type: 0, build_id: retried_coverage_fuzzing_build.id) }
  let!(:retried_api_fuzzing_scan) { security_scans.create!(project_id: project.id, pipeline_id: pipeline.id, scan_type: 0, build_id: retried_api_fuzzing_build.id) }
  let!(:retried_cluster_image_scanning_scan) { security_scans.create!(project_id: project.id, pipeline_id: pipeline.id, scan_type: 0, build_id: retried_cluster_image_scanning_build.id) }

  before do
    artifacts.create!(project_id: project.id, job_id: retried_sast_build.id, file_type: 5)
    artifacts.create!(project_id: project.id, job_id: retried_codequality_build.id, file_type: 9)
    artifacts.create!(project_id: project.id, job_id: latest_sast_build.id, file_type: 5)
    artifacts.create!(project_id: project.id, job_id: retried_dependency_scanning_build.id, file_type: 6)
    artifacts.create!(project_id: project.id, job_id: retried_container_scanning_build.id, file_type: 7)
    artifacts.create!(project_id: project.id, job_id: retried_dast_build.id, file_type: 8)
    artifacts.create!(project_id: project.id, job_id: retried_secret_detection_build.id, file_type: 21)
    artifacts.create!(project_id: project.id, job_id: retried_coverage_fuzzing_build.id, file_type: 23)
    artifacts.create!(project_id: project.id, job_id: retried_api_fuzzing_build.id, file_type: 26)
    artifacts.create!(project_id: project.id, job_id: retried_cluster_image_scanning_build.id, file_type: 27)
  end

  describe '#perform' do
    subject(:populate_latest_column) { migrator.perform(retried_sast_build.id, retried_cluster_image_scanning_build.id) }

    it 'updates the `latest` column of related security scans of retried builds' do
      expect { populate_latest_column }.to change { retried_sast_scan.reload.latest }.from(true).to(false)
                                       .and change { retried_dependency_scanning_scan.reload.latest }.from(true).to(false)
                                       .and change { retried_container_scanning_scan.reload.latest }.from(true).to(false)
                                       .and change { retried_dast_scan.reload.latest }.from(true).to(false)
                                       .and change { retried_secret_detection_scan.reload.latest }.from(true).to(false)
                                       .and change { retried_coverage_fuzzing_scan.reload.latest }.from(true).to(false)
                                       .and change { retried_api_fuzzing_scan.reload.latest }.from(true).to(false)
                                       .and change { retried_cluster_image_scanning_scan.reload.latest }.from(true).to(false)
                                       .and not_change { latest_sast_scan.reload.latest }.from(true)
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
