# frozen_string_literal: true

module Projects
  # Service class for counting and caching the number of open issues of a
  # project.
  class OpenIssuesCountService < Projects::CountService
    include Gitlab::Utils::StrongMemoize

    # Cache keys used to store issues count
    # TOTAL_COUNT_KEY includes confidential issues and banned user issues (admin)
    # TOTAL_COUNT_WITHOUT_BANNED_KEY includes confidential issues but not banned user issues (member)
    # PUBLIC_COUNT_WITHOUT_BANNED_KEY does not include confidential issues or banned user issues (non-member)
    TOTAL_COUNT_KEY = 'open_issues_including_banned_count'
    TOTAL_COUNT_WITHOUT_BANNED_KEY = 'open_issues_without_banned_count'
    PUBLIC_COUNT_WITHOUT_BANNED_KEY = 'open_public_issues_without_banned_count'

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
        with_banned_issues = self.class.query(@project, include_banned: true)
        without_banned_issues = self.class.query(@project, include_banned: false)

        without_banned_count_grouped_by_confidential = without_banned_issues.group(:confidential).count

        total_public_without_banned_count = without_banned_count_grouped_by_confidential[false] || 0
        total_confidential_without_banned_count = without_banned_count_grouped_by_confidential[true] || 0

        update_cache_for_key(total_count_cache_key) do
          with_banned_issues.count
        end

        update_cache_for_key(public_count_without_banned_cache_key) do
          total_public_without_banned_count
        end

        update_cache_for_key(total_count_without_banned_cache_key) do
          total_public_without_banned_count + total_confidential_without_banned_count
        end
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    # We only show total issues count for admins who are allowed to view issues created by banned users.
    # We also only show issues count including confidential for reporters.
    # This will still show a discrepancy on issues number but should be less than before.
    # Check https://gitlab.com/gitlab-org/gitlab-foss/issues/38418 description.
    # rubocop: disable CodeReuse/ActiveRecord
    def self.query(projects, include_banned: true)
      issues_filtered_by_type = Issue.opened.with_issue_type(Issue::TYPES_FOR_LIST)

      if include_banned
        issues_filtered_by_type.where(project: projects)
      else
        issues_filtered_by_type.where(project: projects).joins(:author).where("users.state != 'banned'")
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
