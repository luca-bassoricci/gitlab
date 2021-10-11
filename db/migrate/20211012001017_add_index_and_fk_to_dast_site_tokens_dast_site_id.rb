# frozen_string_literal: true
class AddIndexAndFkToDastSiteTokensDastSiteId < Gitlab::Database::Migration[1.0]
  disable_ddl_transaction!

  INDEX_NAME = :index_dast_site_tokens_on_dast_site_id

  def up
    add_concurrent_index :dast_site_tokens, :dast_site_id, name: INDEX_NAME, unique: true

    add_foreign_key :dast_site_tokens, :dast_sites, on_delete: :cascade, validate: false
  end

  def down
    remove_foreign_key_if_exists :dast_site_tokens, column: :dast_site_id

    remove_concurrent_index :dast_site_tokens, :dast_site_id, name: INDEX_NAME
  end
end
