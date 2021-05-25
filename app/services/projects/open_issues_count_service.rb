# frozen_string_literal: true

module Projects
  # Service class for counting and caching the number of open issues of a
  # project.
  class OpenIssuesCountService < Projects::CountService
    include Gitlab::Utils::StrongMemoize

    # Cache keys used to store issues count
    TOTAL_COUNT_WITHOUT_BANNED_KEY = 'total_open_issues_without_banned_count'
    TOTAL_COUNT_KEY = 'total_open_issues_count'
    PUBLIC_COUNT_WITHOUT_BANNED_KEY = 'public_open_issues_without_banned_count'

    def initialize(project, user = nil)
      @user = user

      super(project)
    end

    def cache_key_name
      if user_is_admin
        TOTAL_COUNT_KEY
      else
        public_only? ? PUBLIC_COUNT_WITHOUT_BANNED_KEY : TOTAL_COUNT_WITHOUT_BANNED_KEY
      end
    end

    def public_only?
      !user_is_at_least_reporter?
    end

    def user_is_at_least_reporter?
      strong_memoize(:user_is_at_least_reporter) do
        @user && @project.team.member?(@user, Gitlab::Access::REPORTER)
      end
    end

    def user_is_admin
      @user&.can_admin_all_resources?
    end

    def total_count_without_banned_cache_key
      cache_key(TOTAL_COUNT_WITHOUT_BANNED_KEY)
    end

    def total_count_cache_key
      cache_key(TOTAL_COUNT_KEY)
    end

    def public_count_without_banned_cache_key
      cache_key(PUBLIC_COUNT_WITHOUT_BANNED_KEY)
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def refresh_cache(&block)
      if block_given?
        super(&block)
      else
        count_grouped_by_confidential = self.class.query(@project, public_only: false).group(:confidential).count

        total_count_without_banned = count_grouped_by_confidential[false] || 0
        total_count = total_count_without_banned + (count_grouped_by_confidential[true] || 0)
        banned_count = Issue.joins(:author).where(project: @project).where("users.state = 'banned'").count
        public_count_without_banned = total_count_without_banned - banned_count

        update_cache_for_key(total_count_without_banned_cache_key) do
          total_count_without_banned
        end

        update_cache_for_key(total_count_cache_key) do
          total_count
        end

        update_cache_for_key(public_count_without_banned_cache_key) do
          public_count_without_banned
        end
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    # We only show total issues count for reporters
    # which are allowed to view confidential issues
    # This will still show a discrepancy on issues number but should be less than before.
    # Check https://gitlab.com/gitlab-org/gitlab-foss/issues/38418 description.
    # rubocop: disable CodeReuse/ActiveRecord
    def self.query(projects, public_only: true)
      issues_filtered_by_type = Issue.opened.with_issue_type(Issue::TYPES_FOR_LIST)

      if public_only
        issues_filtered_by_type.public_only.where(project: projects)
      else
        issues_filtered_by_type.where(project: projects)
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
