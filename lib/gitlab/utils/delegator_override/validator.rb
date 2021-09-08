# frozen_string_literal: true

module Gitlab
  module Utils
    module DelegatorOverride
      UnexpectedDelegatorOverrideError = Class.new(StandardError)

      class Validator
        attr_reader :delegator_klass, :target_klass, :error_header, :ancestor_validators

        OVERRIDE_ERROR_MESSAGE = <<~EOS
          We've detected that a presetner is overriding a specific method(s) on a subject model.
          There is a risk that it accidentally modifies the backend/core logic that leads to production incident.
          Please follow https://docs.gitlab.com/ee/development/reusing_abstractions.html#validate-accidental-overrides
          to resolve this error with caution.
        EOS

        def initialize(delegator_klass)
          @delegator_klass = delegator_klass
          @ancestor_validators = []
        end

        def add_allowlist(names)
          method_names.concat(names)
        end

        def method_names
          @method_names ||= []
        end

        def set_target(target_klass)
          @target_klass = target_klass
        end

        def set_error_header(error_header)
          @error_header = error_header
        end

        def with(ancestor_validators)
          tap { @ancestor_validators = ancestor_validators }
        end

        def validate_overrides!
          return unless target_klass

          errors = []

          (delegator_klass.instance_methods - allowlist).each do |name|
            target_klass.new rescue nil # Workaround to fully load the instance methods in the target class

            if target_klass.instance_methods.include?(name)
              target_location = extract_location(target_klass, name)
              delegator_location = extract_location(delegator_klass, name)
              errors << Error.new(target_klass, name, target_location, delegator_klass, delegator_location)
            end
          end

          if errors.any?
            details = errors.map { |error| "- #{error}" }.join("\n")

            raise UnexpectedDelegatorOverrideError,
              <<~TEXT
                #{OVERRIDE_ERROR_MESSAGE}
                Here are the conflict details.

                #{details}
              TEXT
          end
        end

        private

        def extract_location(klass, name)
          klass.instance_method(name).source_location.join(':')
        end

        def allowlist
          allowed = []
          allowed.concat(method_names)
          allowed.concat(ancestor_validators.flat_map(&:method_names))
          allowed.concat(Object.instance_methods)
          allowed.concat(::Delegator.instance_methods)
          allowed.concat(::Presentable.instance_methods)
          allowed
        end
      end
    end
  end
end
