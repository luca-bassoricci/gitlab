# frozen_string_literal: true

class CreateAlertManagementAlertMetricImages < Gitlab::Database::Migration[1.0]
  disable_ddl_transaction!
  def up
    create_table :alert_management_alert_metric_images do |t|
      t.references :alert, null: false, index: true, foreign_key: { to_table: :alert_management_alerts, on_delete: :cascade }
      t.timestamps_with_timezone
      t.integer :file_store, limit: 2
      t.text :file, null: false
      t.text :url
      t.text :url_text
    end

    add_text_limit(:alert_management_alert_metric_images, :url, 255)
    add_text_limit(:alert_management_alert_metric_images, :file, 255)
    add_text_limit(:alert_management_alert_metric_images, :url_text, 128)
  end

  def down
    drop_table :alert_management_alert_metric_images, if_exists: true
  end
end
