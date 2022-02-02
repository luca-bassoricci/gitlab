# frozen_string_literal: true

module AlertManagement
  class MetricImage < ApplicationRecord
    include MetricImageUploading

    self.table_name = 'alert_management_alert_metric_images'

    belongs_to :alert, class_name: 'AlertManagement::Alert', foreign_key: 'alert_id', inverse_of: :metric_images

    def self.available_for?(project)
      project&.feature_available?(:alert_metric_upload)
    end

    def full_model_name
      model_name.param_key
    end

    private

    def local_path
      Gitlab::Routing.url_helpers.alert_metric_image_upload_path(
        filename: file.filename,
        id: file.upload.model_id,
        model: full_model_name,
        mounted_as: 'file'
      )
    end
  end
end
