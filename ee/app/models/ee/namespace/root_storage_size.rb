# frozen_string_literal: true

module EE
  class Namespace::RootStorageSize
    CURRENT_SIZE_CACHE_KEY = 'root_storage_current_size'
    LIMIT_CACHE_KEY = 'root_storage_size_limit'
    EXPIRATION_TIME = 10.minutes

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
      # Refactor in https://gitlab.com/gitlab-org/gitlab/-/issues/366938
      # rubocop:disable CodeReuse/ServiceClass
      ::Namespaces::Storage::EnforcementCheckService.enforce_limit?(root_namespace)
      # rubocop:enable CodeReuse/ServiceClass
    end

    alias_method :enabled?, :enforce_limit?

    def error_message
      @error_message_object ||= ::EE::Gitlab::NamespaceStorageSizeErrorMessage.new(self)
    end

    def exceeded_size(change_size = 0)
      size = current_size + change_size - limit

      [size, 0].max
    end

    def changes_will_exceed_size_limit?(change_size)
      limit != 0 && exceeded_size(change_size) > 0
    end

    private

    attr_reader :root_namespace

    delegate :gitlab_subscription, to: :root_namespace
  end
end
