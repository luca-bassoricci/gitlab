# frozen_string_literal: true

class CreateAlertManagementMetricImageRegistry < Gitlab::Database::Migration[2.0]
  disable_ddl_transaction!

  def up
    Geo::TrackingBase.transaction do
      create_table :alert_metric_image_registry, id: :bigserial, force: :cascade do |t|
        t.bigint :alert_metric_image_id, null: false
        t.datetime_with_timezone :created_at, null: false
        t.datetime_with_timezone :last_synced_at
        t.datetime_with_timezone :retry_at
        t.datetime_with_timezone :verified_at
        t.datetime_with_timezone :verification_started_at
        t.datetime_with_timezone :verification_retry_at
        t.integer :state, default: 0, null: false, limit: 2
        t.integer :verification_state, default: 0, null: false, limit: 2
        t.integer :retry_count, default: 0, limit: 2, null: false
        t.integer :verification_retry_count, default: 0, limit: 2, null: false
        t.boolean :checksum_mismatch, default: false, null: false
        t.binary :verification_checksum
        t.binary :verification_checksum_mismatched
        t.text :verification_failure, limit: 255
        t.text :last_sync_failure, limit: 255

        t.index :alert_metric_image_id, name: :index_alert_metric_image_registry_on_alert_metric_image_id, unique: true
        t.index :retry_at
        t.index :state

        t.index :verification_retry_at, name: :alert_metric_image_registry_failed_verification,
                                        order: "NULLS FIRST",
                                        where: "((state = 2) AND (verification_state = 3))"

        t.index :verification_state, name: :alert_metric_image_registry_needs_verification,
                                     where: "((state = 2) AND (verification_state = ANY (ARRAY[0, 3])))"

        t.index :verified_at, name: :alert_metric_image_registry_pending_verification,
                              order: "NULLS FIRST",
                              where: "((state = 2) AND (verification_state = 0))"
      end
    end
  end

  def down
    drop_table :alert_metric_image_registry
  end
end
