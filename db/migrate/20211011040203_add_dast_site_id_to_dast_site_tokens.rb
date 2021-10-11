# frozen_string_literal: true

class AddDastSiteIdToDastSiteTokens < Gitlab::Database::Migration[1.0]
  def up
    add_column :dast_site_tokens, :dast_site_id, :bigint, null: false, default: 0
  end

  def down
    remove_column :dast_site_tokens, :dast_site_id
  end
end
