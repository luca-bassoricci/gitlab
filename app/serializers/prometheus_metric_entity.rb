# frozen_string_literal: true

class PrometheusMetricEntity < Grape::Entity
  include RequestAwareEntity

  expose :id
  expose :title

  expose :group
  expose :group_title
  expose :unit
end
