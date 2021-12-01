# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents environment variables.
        #
        class Variables < ::Gitlab::Config::Entry::ComposableHash
          include ::Gitlab::Config::Entry::Validatable

          validations do
            validates :config, type: Hash
          end

          def value
            @entries.values.map(&:value)
          end

          def self.default(**)
            {}
          end

          private

          def composable_class(name, config)
            Entry::Variable
          end
        end
      end
    end
  end
end
