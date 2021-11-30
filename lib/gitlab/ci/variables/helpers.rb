# frozen_string_literal: true

module Gitlab
  module Ci
    module Variables
      module Helpers
        class << self
          def merge_variables(current_vars, new_vars)
            new_var_keys = Array(new_vars).map { |var| var[:key] }
            unique_current_vars = Array(current_vars).reject { |var| var[:key].in?(new_var_keys) }

            transform_to_yaml_variables(unique_current_vars + Array(new_vars))
          end

          def transform_to_yaml_variables(vars)
            Array(vars).map do |var_hash|
              { **var_hash, public: true }
            end
          end

          def inherit_yaml_variables(from:, to:, inheritance:)
            merge_variables(apply_inheritance(from, inheritance), to)
          end

          private

          def apply_inheritance(variables, inheritance)
            case inheritance
            when true then variables
            when false then {}
            when Array then variables.select { |var| inheritance.include?(var[:key]) }
            end
          end
        end
      end
    end
  end
end
