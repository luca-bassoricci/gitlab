# frozen_string_literal: true

class SchedulePopulateSecurityScansLatestColumn < Gitlab::Database::Migration[1.0]
  DELAY_INTERVAL = 2.minutes.to_i
  BATCH_SIZE = 1000
  MIGRATION = 'PopulateSecurityScansLatestColumn'

  disable_ddl_transaction!

  def up
    return unless Gitlab.ee?

    queue_background_migration_jobs_by_range_at_intervals(
      Gitlab::BackgroundMigration::PopulateSecurityScansLatestColumn.builds,
      MIGRATION,
      DELAY_INTERVAL,
      batch_size: BATCH_SIZE
    )
  end

  def down
    # no-op
  end
end
