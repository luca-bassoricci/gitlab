# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        class Variable < ::Gitlab::Config::Entry::Simplifiable
          strategy :SimpleVariable, if: -> (config) { !config.is_a?(Hash) }
          strategy :VariableHash, if: -> (config) { config.is_a?(Hash) }

          class SimpleVariable < ::Gitlab::Config::Entry::Node
            include ::Gitlab::Config::Entry::Validatable

            validations do
              validate do
                if @config.to_s.nil?
                  errors.add(:config, "config can't be blank")
                end
              end
            end

            def value
              {
                key: key.to_s,
                value: @config.to_s
              }
            end
          end

          class VariableHash < ::Gitlab::Config::Entry::Node
            include ::Gitlab::Config::Entry::Validatable

            ALLOWED_KEYS = %i[value description].freeze

            validations do
              validates :config, allowed_keys: ALLOWED_KEYS
            end

            def value
              {
                key: key.to_s,
                **@config
              }
            end
          end

          class UnknownStrategy < ::Gitlab::Config::Entry::Node
            def value
            end

            def errors
              ["#{location} has an unsupported type"]
            end
          end
        end
      end
    end
  end
end
