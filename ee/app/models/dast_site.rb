# frozen_string_literal: true

class DastSite < ApplicationRecord
  belongs_to :project
  belongs_to :dast_site_validation

  has_many :dast_site_profiles

  has_one :dast_site_token, required: false

  validates :url, length: { maximum: 255 }, uniqueness: { scope: :project_id }
  validates :url, addressable_url: true

  validates :project_id, presence: true
  validate :dast_site_validation_project_id_fk

  private

  def dast_site_validation_project_id_fk
    return unless dast_site_validation_id

    if project_id != dast_site_validation.project.id
      errors.add(:project_id, 'does not match dast_site_validation.project')
    end
  end
end
