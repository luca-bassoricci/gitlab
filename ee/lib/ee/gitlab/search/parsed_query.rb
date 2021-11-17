# frozen_string_literal: true

module EE
  module Gitlab
    module Search
      module ParsedQuery
        WILDCARD_PREFIX_REGEX = /\A(\*+)(?=.*)/.freeze

        def elasticsearch_filter_context(object)
          {
            filter: including_filters.map { |f| prepare_for_elasticsearch(object, f) },
            must_not: excluding_filters.map { |f| prepare_for_elasticsearch(object, f) }
          }
        end

        private

        def prepare_for_elasticsearch(object, filter)
          type = filter[:type] || :wildcard
          field = filter[:field] || filter[:name]
          value = filter[:value]

          if Feature.enabled?(:remove_wildcard_prefixes_from_elasticsearch_queries)
            # Remove wildcard prefix from Elasticsearch queries because they
            # force Elasticsearch to search through every possible location in
            # the index for a match.
            value.gsub!(WILDCARD_PREFIX_REGEX, "")
          end

          {
            type => {
              "#{object}.#{field}" => value
            }
          }
        end
      end
    end
  end
end
