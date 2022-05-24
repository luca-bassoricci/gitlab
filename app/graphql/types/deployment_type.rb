# frozen_string_literal: true

module Types
  class DeploymentType < BaseObject
    graphql_name 'Deployment'

    authorize :read_deployment

    field :id, Types::GlobalIDType[Deployment],
          null: false,
          description: 'Global identifier of the deployment.'
    field :iid, GraphQL::Types::ID,
          null: false,
          description: 'Internal identifier of the deployment.'
    field :ref, GraphQL::Types::String,
          null: false,
          description: 'Reference that was deployed.'
    field :sha, GraphQL::Types::String,
          null: false,
          description: 'SHA of the commit that was deployed.'
    field :tag, GraphQL::Types::Boolean,
          null: false,
          description: 'True if this is a tagged deployment.'
    field :created_at, Types::TimeType,
          null: true,
          description: 'When this deployment was created.'
    field :updated_at, Types::TimeType,
          null: true,
          description: 'When this deployment was last updated.'
    field :finished_at, Types::TimeType,
          null: true,
          description: 'When this deployment was completed.'
    field :status, Types::DeploymentStatusEnum,
          null: false,
          description: 'Status of the deployment.'
    field :archived, GraphQL::Types::Boolean,
          null: false,
          description: 'True if this deployment has been archived.'

    field :project, Types::ProjectType, null: false,
          description: 'Project of the deployment.'
    field :environment, Types::EnvironmentType, null: false,
          description: 'Environment of the deployment.'
    field :cluster, Types::ClusterType, null: true,
          description: 'Cluster this was deployed to.'
    field :user, Types::UserType, null: true,
          description: 'User that performed the deployment.'

    def environment
      Gitlab::Graphql::BatchModelLoader.new(Environment, object.environment_id).find
    end

    def cluster
      Gitlab::Graphql::BatchModelLoader.new(Clusters::Cluster, object.cluster_id).find
    end

    def user
      Gitlab::Graphql::BatchModelLoader.new(User, object.user_id).find
    end
  end
end
