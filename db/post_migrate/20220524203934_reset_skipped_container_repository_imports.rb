# frozen_string_literal: true

class ResetSkippedContainerRepositoryImports < Gitlab::Database::Migration[2.0]
  disable_ddl_transaction!

  restrict_gitlab_migration gitlab_schema: :gitlab_main

  def up
    ContainerRepository.where(migration_state: 'import_skipped').each_batch(of: 20) do |batch|
      batch.update_all(
        migration_pre_import_started_at: nil,
        migration_pre_import_done_at: nil,
        migration_import_started_at: nil,
        migration_import_done_at: nil,
        migration_aborted_at: nil,
        migration_skipped_at: nil,
        migration_retries_count: 0,
        migration_skipped_reason: nil,
        migration_state: 'default',
        migration_aborted_in_state: nil
      )
    end
  end

  def down
    # no-op
  end
end
