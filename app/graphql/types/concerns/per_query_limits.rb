# frozen_string_literal: true

# Concern to limit the instantiation of a type in a single query context
#
# Including modules may provide a class method named `per_query_limit` to set
# the limit, which otherwise defaults to `PER_QUERY_LIMIT`.
module PerQueryLimits
  extend ActiveSupport::Concern
  TooManyInstances = Class.new(::Gitlab::Graphql::Errors::BaseError)

  PER_QUERY_LIMIT = 10

  included do
    def self.authorized_new(object, context)
      counts = (context[:per_query_counts] ||= Hash.new(0))
      current_count = counts[self]
      limit = [try(:per_query_limit), PER_QUERY_LIMIT].compact.first

      raise TooManyInstances, "Maximum of #{limit} instances of #{graphql_name} per query" if current_count >= limit

      super
    ensure
      counts[self] += 1
    end
  end
end
