# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents environment variables.
        #
        class Variables < ::Gitlab::Config::Entry::Node
          include ::Gitlab::Config::Entry::Validatable

          ALLOWED_VALUE_DATA = %i[value description].freeze

          validations do
            validates :config, variables: { allowed_value_data: ALLOWED_VALUE_DATA }, if: :use_value_data?
            validates :config, variables: true, unless: :use_value_data?
          end

          def value
            @config.map do |key, value|
              {
                key: key.to_s,
                **expand_value(value)
              }
            end
          end

          def self.default(**)
            {}
          end

          def use_value_data?
            opt(:use_value_data)
          end

          private

          def expand_value(value)
            if value.is_a?(Hash)
              { value: value[:value].to_s }.tap do |hash|
                hash[:description] = value[:description].to_s if value[:description]
              end
            else
              { value: value.to_s }
            end
          end
        end
      end
    end
  end
end
