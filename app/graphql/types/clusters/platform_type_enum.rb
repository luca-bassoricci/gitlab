# frozen_string_literal: true

module Types
  module Clusters
    class PlatformTypeEnum < BaseEnum
      graphql_name 'ClusterPlatformType'
      description 'All supported cluster platforms.'

      value 'KUBERNETES', description: 'Kubernetes.', value: :kubernetes
    end
  end
end
