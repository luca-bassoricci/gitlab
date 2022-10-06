# frozen_string_literal: true

module Geo
  class AlertMetricImageState < ApplicationRecord
    include EachBatch
    include ::Geo::VerificationStateDefinition

    self.primary_key = :alert_metric_image_id

    belongs_to :alert_metric_image, inverse_of: :alert_metric_image_state

    validates :verification_failure, length: { maximum: 255 }
    validates :verification_state, :alert_metric_image, presence: true
  end
end
