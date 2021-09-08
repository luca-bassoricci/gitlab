# frozen_string_literal: true

module Gitlab
  module Utils
    module DelegatorOverride
      class Error
        attr_accessor :target_klass, :name, :target_location, :delegator_klass, :delegator_location

        def initialize(target_klass, name, target_location, delegator_klass, delegator_location)
          @target_klass = target_klass
          @name = name
          @target_location = target_location
          @delegator_klass = delegator_klass
          @delegator_location = delegator_location
        end

        def to_s
          "#{delegator_klass}##{name} is overriding #{target_klass}##{name}. delegator_location: #{delegator_location} target_location: #{target_location}"
        end
      end
    end
  end
end
