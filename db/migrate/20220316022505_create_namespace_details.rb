# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateNamespaceDetails < Gitlab::Database::Migration[1.0]
  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :namespace_details, id: false do |t|
        t.timestamps_with_timezone null: false
        t.text :description, limit: 255
        t.text :description_html, limit: 255
        t.integer :cached_markdown_version
        t.references :namespace, primary_key: true, null: false, default: nil, type: :bigint, index: false, foreign_key: { on_delete: :cascade } # rubocop:disable Layout/LineLength
      end
    end
  end

  def down
    drop_table :namespace_details
  end
end
