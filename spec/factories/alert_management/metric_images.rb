# frozen_string_literal: true

FactoryBot.define do
  factory :alert_metric_image, class: 'AlertManagement::MetricImage' do
    association :alert, factory: :alert_management_alert
    url { generate(:url) }

    trait :local do
      file_store { ObjectStorage::Store::LOCAL }
    end

    trait :verification_succeeded do
      with_file
      verification_checksum { 'abc' }
      verification_state { AlertManagement::MetricImage.verification_state_value(:verification_succeeded) }
    end

    trait :verification_failed do
      with_file
      verification_failure { 'Could not calculate the checksum' }
      verification_state { AlertManagement::MetricImage.verification_state_value(:verification_failed) }
    end

    after(:build) do |image|
      image.file = fixture_file_upload('spec/fixtures/rails_sample.jpg', 'image/jpg')
    end
  end
end
