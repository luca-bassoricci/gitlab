# frozen_string_literal: true

class CleanUpOrphanedDastSiteTokens < Gitlab::Database::Migration[1.0]
  class DastSite < ApplicationRecord
    self.table_name = 'dast_sites'
    self.inheritance_column = :_type_disabled
  end

  class DastSiteToken < ApplicationRecord
    self.table_name = 'dast_site_tokens'
    self.inheritance_column = :_type_disabled
  end

  def up
    results = DastSiteToken
                .joins('INNER JOIN dast_sites ON dast_sites.url = dast_site_tokens.url AND dast_sites.project_id = dast_site_tokens.project_id')
                .pluck('id', 'project_id', 'created_at', 'updated_at', 'expired_at', 'token', 'url', 'dast_sites.id')

    attributes = results.map do |id, project_id, created_at, updated_at, expired_at, token, url, dast_site_id|
      {
        id: id,
        project_id: project_id,
        created_at: created_at,
        updated_at: updated_at,
        expired_at: expired_at,
        token: token,
        url: url,
        dast_site_id: dast_site_id
      }
    end

    unless attributes.empty?
      DastSiteToken.upsert_all(attributes, unique_by: :id)
    end

    DastSiteToken.where(dast_site_id: 0).delete_all
  end

  def down
    # no rollback possible
  end
end
