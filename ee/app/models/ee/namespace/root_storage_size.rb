# frozen_string_literal: true

module EE
  class Namespace::RootStorageSize
    CURRENT_SIZE_CACHE_KEY = 'root_storage_current_size'
    LIMIT_CACHE_KEY = 'root_storage_size_limit'
    EXPIRATION_TIME = 10.minutes
    EFFECTIVE_DATE = 99.years.from_now.to_date
    ENFORCEMENT_DATE = 100.years.from_now.to_date

    def initialize(root_namespace)
      @root_namespace = root_namespace
    end

    def above_size_limit?
      return false unless enforce_limit?
      return false if root_namespace.temporary_storage_increase_enabled?

      usage_ratio > 1
    end

    def usage_ratio
      return 0 if limit == 0

      current_size.to_f / limit.to_f
    end

    def current_size
      @current_size ||= Rails.cache.fetch(['namespaces', root_namespace.id, CURRENT_SIZE_CACHE_KEY], expires_in: EXPIRATION_TIME) do
        root_namespace.root_storage_statistics&.storage_size
      end
    end

    def limit
      @limit ||= Rails.cache.fetch(['namespaces', root_namespace.id, LIMIT_CACHE_KEY], expires_in: EXPIRATION_TIME) do
        root_namespace.actual_limits.storage_size_limit.megabytes +
            root_namespace.additional_purchased_storage_size.megabytes
      end
    end

    def remaining_storage_percentage
      [(100 - usage_ratio * 100).floor, 0].max
    end

    def remaining_storage_size
      [limit - current_size, 0].max
    end

    def enforce_limit?
      return false unless enforceable_dates?
      return false if root_namespace.opensource_plan?

      return ::Feature.enabled?(:enforce_storage_limit_for_paid, root_namespace) if root_namespace.paid?

      ::Feature.enabled?(:enforce_storage_limit_for_free, root_namespace)
    end

    private

    def enforceable_dates?
      ::Feature.enabled?(:namespace_storage_limit_bypass_date_check, root_namespace) ||
        (Date.current >= ENFORCEMENT_DATE && gitlab_subscription.start_date >= EFFECTIVE_DATE)
    end

    attr_reader :root_namespace

    delegate :gitlab_subscription, to: :root_namespace
  end
end
