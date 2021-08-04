# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class RenameBuildFinishedQueue < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  def up
    sidekiq_queue_migrate 'pipeline_processing:build_finished', to: 'pipeline_processing:ci_build_finished'
    sidekiq_queue_migrate 'pipeline_background:archive_trace', to: 'pipeline_background:ci_archive_trace'
  end

  def down
    sidekiq_queue_migrate 'pipeline_processing:ci_build_finished', to: 'pipeline_processing:build_finished'
    sidekiq_queue_migrate 'pipeline_background:ci_archive_trace', to: 'pipeline_background:archive_trace'
  end
end
