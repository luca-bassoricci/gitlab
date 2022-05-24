# frozen_string_literal: true

module Types
  class ClusterType < BaseObject
    graphql_name 'Cluster'

    authorize :read_cluster

    field :id, Types::GlobalIDType[Clusters::Cluster],
          null: false,
          description: 'Global identifier of the cluster.'
    field :name, GraphQL::Types::String,
          null: false,
          description: 'Name of the cluster.'
    field :domain, GraphQL::Types::String,
          null: true,
          description: 'Domain of the cluster.'
    field :environment_scope, GraphQL::Types::String,
          null: true,
          description: 'Environment scope of the cluster.'
    field :managed, GraphQL::Types::Boolean,
          null: false,
          description: 'True if the cluster is managed.'
    field :enabed, GraphQL::Types::Boolean,
          null: true,
          description: 'True if the cluster is enabled.'
    field :platform_type, Types::Clusters::PlatformTypeEnum,
          null: true,
          description: 'The platform this cluster is on.'
    field :provider_type, Types::Clusters::ProviderTypeEnum,
          null: true,
          description: 'The provider of this cluster.'
  end
end
