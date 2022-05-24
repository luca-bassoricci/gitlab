# frozen_string_literal: true

module Resolvers
  module MergeRequests
    class DeploymentsResolver < BaseResolver
      include ::CachingArrayResolver

      type ::Types::DeploymentType.array_type, null: true

      alias_method :merge_request, :object

      def query_for(mr)
        mr.recent_visible_deployments # limited to 10 per mr
      end

      def model_class
        ::Deployment
      end

      def query_input(**args)
        merge_request
      end

      # Avoid redundant lookups for Deployment.project
      def item_found(mr, deployment)
        deployment.project = mr.project
      end
    end
  end
end
