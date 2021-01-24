# frozen_string_literal: true

module Gitlab
  module RedisTracker
    module Event
      class Context
        ALLOWED_CONTEXT = {
          plan: Plan.all_plans
        }.freeze

        def initialize(context = {})
          @context = context
        end

        def to_h
          @context
        end

        def valid?
          return true unless @context.present?

          @context.any? do |key, value|
            ALLOWED_CONTEXT.has_key?(key) && (Array(value) & ALLOWED_CONTEXT[key]) == Array(value)
          end
        end
      end
    end
  end
end
