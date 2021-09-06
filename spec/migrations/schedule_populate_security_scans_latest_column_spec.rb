# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe SchedulePopulateSecurityScansLatestColumn do
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:pipelines) { table(:ci_pipelines) }
  let(:builds) { table(:ci_builds) }
  let(:artifacts) { table(:ci_job_artifacts) }

  let(:namespace) { namespaces.create!(name: 'gitlab', path: 'gitlab-org') }
  let(:project) { projects.create!(namespace_id: namespace.id, name: 'Foo') }
  let(:pipeline)  { pipelines.create!(project_id: project.id, ref: 'master', sha: 'adf43c3a') }

  let(:retried_sast_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_dependency_scanning_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_container_scanning_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_dast_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_secret_detection_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_coverage_fuzzing_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_api_fuzzing_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_cluster_image_scanning_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:retried_codequality_build) { builds.create!(commit_id: pipeline.id, retried: true) }
  let(:latest_sast_build) { builds.create!(commit_id: pipeline.id, retried: false) }

  before do
    allow(Gitlab).to receive(:ee?).and_return(is_ee?)
    stub_const("#{described_class.name}::BATCH_SIZE", 4)

    artifacts.create!(project_id: project.id, job_id: retried_sast_build.id, file_type: 5)
    artifacts.create!(project_id: project.id, job_id: retried_dependency_scanning_build.id, file_type: 6)
    artifacts.create!(project_id: project.id, job_id: retried_container_scanning_build.id, file_type: 7)
    artifacts.create!(project_id: project.id, job_id: retried_dast_build.id, file_type: 8)
    artifacts.create!(project_id: project.id, job_id: retried_secret_detection_build.id, file_type: 21)
    artifacts.create!(project_id: project.id, job_id: retried_coverage_fuzzing_build.id, file_type: 23)
    artifacts.create!(project_id: project.id, job_id: retried_api_fuzzing_build.id, file_type: 26)
    artifacts.create!(project_id: project.id, job_id: retried_cluster_image_scanning_build.id, file_type: 27)
    artifacts.create!(project_id: project.id, job_id: retried_codequality_build.id, file_type: 9)
    artifacts.create!(project_id: project.id, job_id: latest_sast_build.id, file_type: 5)
  end

  around do |example|
    freeze_time { example.run }
  end

  context 'when the installation is FOSS' do
    let(:is_ee?) { false }

    it 'does not schedule any background job' do
      migrate!

      expect(BackgroundMigrationWorker.jobs.size).to be(0)
    end
  end

  context 'when the installation is EE' do
    let(:is_ee?) { true }

    it 'schedules the background jobs' do
      migrate!

      expect(BackgroundMigrationWorker.jobs.size).to be(2)
      expect(described_class::MIGRATION).to be_scheduled_delayed_migration(described_class::DELAY_INTERVAL, retried_sast_build.id, retried_dast_build.id)
      expect(described_class::MIGRATION).to be_scheduled_delayed_migration(2 * described_class::DELAY_INTERVAL, retried_secret_detection_build.id, retried_cluster_image_scanning_build.id)
    end
  end
end
