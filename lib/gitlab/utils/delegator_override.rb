# frozen_string_literal: true

module Gitlab
  module Utils
    # This module is to validate that delegator classes (`SimpleDelegator`) do not
    # accidentally override important logic on the fabricated object.
    module DelegatorOverride
      def delegator_target(target_klass)
        return unless ENV['STATIC_VERIFICATION']

        unless self.ancestors.include?(::SimpleDelegator)
          raise ArgumentError, "'#{self}' is not a subclass of 'Delegator' class."
        end

        DelegatorOverride.validator(self).set_target(target_klass)
      end

      def delegator_override(*name)
        return unless ENV['STATIC_VERIFICATION']
        raise TypeError unless name.all? { |n| n.is_a?(Symbol) }

        DelegatorOverride.validator(self).add_allowlist(name)
      end

      def delegator_override_with(name)
        return unless ENV['STATIC_VERIFICATION']
        raise TypeError unless name.is_a?(Module)

        DelegatorOverride.validator(self).add_allowlist(name.instance_methods)
      end

      def self.validator(delegator_klass)
        validators[delegator_klass] ||= Validator.new(delegator_klass)
      end

      def self.validators
        @validators ||= {}
      end

      def self.verify!
        validators.each_value do |validator|
          # This takes prepended modules into account e.g. `EE::` modules
          ancestor_validators = validators.values_at(*validator.delegator_klass.ancestors).compact
          validator.with(ancestor_validators).validate_overrides! # rubocop: disable CodeReuse/ActiveRecord
        end
      end
    end
  end
end
