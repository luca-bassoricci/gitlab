# frozen_string_literal: true

module Types
  module Geo
    # rubocop:disable Graphql/AuthorizeTypes because it is included
    class AlertMetricImageRegistryType < BaseObject
      graphql_name 'AlertMetricImageRegistry'

      include ::Types::Geo::RegistryType

      description 'Represents the Geo replication and verification state of a alert_metric_image'

      field :alert_metric_image_id, GraphQL::Types::ID, null: false, description: 'ID of the Alert Metric Image.'
    end
    # rubocop:enable Graphql/AuthorizeTypes because it is included
  end
end
