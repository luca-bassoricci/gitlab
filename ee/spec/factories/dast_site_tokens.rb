# frozen_string_literal: true

FactoryBot.define do
  factory :dast_site_token do
    project

    dast_site { association :dast_site, project: project }

    token { SecureRandom.uuid }
  end
end
