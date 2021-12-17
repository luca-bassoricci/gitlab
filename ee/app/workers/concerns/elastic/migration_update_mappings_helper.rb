# frozen_string_literal: true

module Elastic
  module MigrationUpdateMappingsHelper
    def migrate
      if completed?
        log "Skipping updating #{index_name} mapping migration since it is already applied"
        return
      end

      log "Adding #{new_mappings.inspect} to #{index_name} mapping"
      update_mapping!(index_name, { properties: new_mappings })
    end

    def completed?
      helper.refresh_index(index_name: index_name)

      mappings = helper.get_mapping(index_name: index_name)
      flat_mappings = flatten_hash(mappings)

      # Check if mappings include all new_mappings
      flatten_hash(new_mappings).each do |key, value|
        return false if value != flat_mappings[key]
      end

      true
    end

    private

    def index_name
      raise NotImplementedError
    end

    def new_mappings
      raise NotImplementedError
    end

    def update_mapping!(index_name, mappings)
      helper.update_mapping(index_name: index_name, mappings: mappings)
    end

    def flatten_hash(hash)
      hash.each_with_object({}) do |(k, v), h|
        if v.is_a? Hash
          flatten_hash(v).map do |k2, v2|
            h["#{k}.#{k2}"] = v2
          end
        else
          h[k] = v
        end
      end
    end
  end
end
