# frozen_string_literal: true

module AlertManagement
  module MetricImages
    class UploadService < BaseService
      def initialize(alert, current_user, params = {})
        super

        @alert = alert
        @project = alert&.project
        @file = params.fetch(:file)
        @url = params.fetch(:url, nil)
        @url_text = params.fetch(:url_text, nil)
      end

      def execute
        return ServiceResponse.error(message: "Not allowed!") unless alert.metric_images_available? && can_upload_metrics?

        upload_metric

        ServiceResponse.success(payload: { metric: metric, alert: alert })
      rescue ::ActiveRecord::RecordInvalid => e
        ServiceResponse.error(message: e.message)
      end

      attr_reader :alert, :project, :file, :url, :url_text, :metric

      private

      def upload_metric
        @metric = AlertManagement::MetricImage.create!(
          alert: alert,
          file: file,
          url: url,
          url_text: url_text
        )
      end

      def can_upload_metrics?
        current_user&.can?(:upload_alert_management_metric_image, alert)
      end
    end
  end
end
