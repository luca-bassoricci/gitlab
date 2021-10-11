# frozen_string_literal: true

class RemoveDefaultFromDastSiteTokensDastSiteId < Gitlab::Database::Migration[1.0]
  def up
    change_column_default :dast_site_tokens, :dast_site_id, nil
  end

  def down
    change_column_default :dast_site_tokens, :dast_site_id, 0
  end
end
