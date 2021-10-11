# frozen_string_literal: true

class DastSiteToken < ApplicationRecord
  include IgnorableColumns

  ignore_column :url, remove_with: '14.5', remove_after: '2021-11-22'

  belongs_to :project
  belongs_to :dast_site

  validates :project_id, presence: true
  validates :token, length: { maximum: 255 }, presence: true, uniqueness: true
  validates :dast_site_id, presence: true

  delegate :url, to: :dast_site
end
