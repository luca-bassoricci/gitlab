# frozen_string_literal: true

class IssuableMetricImage < ApplicationRecord
  include MetricImageUploading

  belongs_to :issue, class_name: 'Issue', foreign_key: 'issue_id', inverse_of: :metric_images

  attribute :file_store, :integer, default: -> { MetricImageUploader.default_store }

  mount_file_store_uploader MetricImageUploader

  validates :issue, presence: true

  def self.available_for?(project)
    project&.feature_available?(:incident_metric_upload)
  end

  private

  def local_path
    Gitlab::Routing.url_helpers.issuable_metric_image_upload_path(
      filename: file.filename,
      id: file.upload.model_id,
      model: self.class.name.underscore,
      mounted_as: 'file'
    )
  end
end
