# frozen_string_literal: true

FactoryBot.define do
  factory :geo_alert_metric_image_state, class: 'Geo::AlertManagement::MetricImageState' do
    alert_metric_image

    trait(:checksummed) do
      verification_checksum { 'abc' }
    end

    trait(:checksum_failure) do
      verification_failure { 'Could not calculate the checksum' }
    end
  end
end
