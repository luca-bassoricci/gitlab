# frozen_string_literal: true

FactoryBot.modify do
  factory :project_member do
    trait :awaiting do
      after(:create) do |member|
        member.wait
      end
    end

    trait :active do
      after(:create) do |member|
        member.activate
      end
    end

    trait :created do
      after(:create) do |member|
        member.update!(state: Member::STATE_CREATED)
      end
    end
  end
end
