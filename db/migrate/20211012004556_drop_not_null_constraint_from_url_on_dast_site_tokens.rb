# frozen_string_literal: true

class DropNotNullConstraintFromUrlOnDastSiteTokens < Gitlab::Database::Migration[1.0]
  def change
    change_column_null :dast_site_tokens, :url, true
  end
end
