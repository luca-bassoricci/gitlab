# frozen_string_literal: true

module Groups
  # Service class for counting and caching the number of open issues of a group.
  class OpenIssuesCountService < Groups::CountService
    TOTAL_COUNT_KEY = 'group_total_open_issues_count'
    TOTAL_COUNT_WITHOUT_BANNED_KEY = 'group_total_open_issues_without_banned_count'
    PUBLIC_COUNT_WITHOUT_BANNED_KEY = 'group_public_open_issues_without_banned_count'

    def clear_all_cache_keys
      [cache_key(TOTAL_COUNT_KEY), cache_key(TOTAL_COUNT_WITHOUT_BANNED_KEY), cache_key(PUBLIC_COUNT_WITHOUT_BANNED_KEY)].each do |key|
        Rails.cache.delete(key)
      end
    end

    def cache_key_name
      if user_is_admin?
        TOTAL_COUNT_KEY
      else
        public_only? ? PUBLIC_COUNT_WITHOUT_BANNED_KEY : TOTAL_COUNT_WITHOUT_BANNED_KEY
      end
    end

    private

    def public_only?
      !user_is_at_least_reporter?
    end

    def user_is_at_least_reporter?
      strong_memoize(:user_is_at_least_reporter) do
        group.member?(user, Gitlab::Access::REPORTER)
      end
    end

    def user_is_admin?
      strong_memoize(:user_is_admin) do
        user&.can_admin_all_resources?
      end
    end

    def relation_for_count
      IssuesFinder.new(
        user,
        group_id: group.id,
        state: 'opened',
        non_archived: true,
        include_subgroups: true,
        public_only: public_only?
      ).execute
    end

    def issuable_key
      'open_issues'
    end
  end
end
