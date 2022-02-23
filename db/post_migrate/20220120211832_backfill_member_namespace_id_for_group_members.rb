# frozen_string_literal: true

class BackfillMemberNamespaceIdForGroupMembers < Gitlab::Database::Migration[1.0]
  MIGRATION = 'BackfillMemberNamespaceForGroupMembers'
  INTERVAL = 2.minutes
  BATCH_SIZE = 1_000
  MAX_BATCH_SIZE = 2_000
  SUB_BATCH_SIZE = 100

  def up
    queue_batched_background_migration(
      MIGRATION,
      :members,
      :id,
      job_interval: INTERVAL,
      batch_size: BATCH_SIZE,
      max_batch_size: MAX_BATCH_SIZE,
      max_batch_value: 6_000_000, #5_700_754,
      sub_batch_size: SUB_BATCH_SIZE
    )
  end

  def down
    Gitlab::Database::BackgroundMigration::BatchedMigration
      .for_configuration(MIGRATION, :members, :id, [])
      .delete_all
  end
end
