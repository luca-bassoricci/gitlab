# frozen_string_literal: true
FactoryBot.define do
  factory :ml_candidates, class: '::Ml::Candidate' do
    association :experiment, factory: :ml_experiments
    association :user

    trait :with_metrics do
      after(:create) do |candidate|
        candidate.metrics = FactoryBot.create_list(:ml_candidate_metrics, 2, candidate: candidate )
      end
    end
  end
end
