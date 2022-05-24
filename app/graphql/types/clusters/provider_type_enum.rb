# frozen_string_literal: true

module Types
  module Clusters
    class PlatformTypeEnum < BaseEnum
      graphql_name 'ClusterPlatformType'
      description 'All supported cluster platforms.'

      value 'USER', description: 'Self hosted.', value: :user
      value 'GCP', description: 'Google Cloud Platform (GCP).', value: :gcp
      value 'AWS', description: 'Amazon Web Services (AWS).', value: :aws
    end
  end
end
