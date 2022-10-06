# frozen_string_literal: true

module Geo
  class AlertMetricImageRegistry < Geo::BaseRegistry
    include ::Geo::ReplicableRegistry
    include ::Geo::VerifiableRegistry

    MODEL_CLASS = ::AlertManagement::MetricImage
    MODEL_FOREIGN_KEY = :alert_metric_image_id

    belongs_to :alert_metric_image, class_name: 'AlertManagement::MetricImage'
  end
end
