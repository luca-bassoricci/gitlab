# frozen_string_literal: true

module Gitlab
  module UsageDataCounters
    module IssueActivityUniqueCounter
      ISSUE_CATEGORY = 'issues_edit'

      ISSUE_ASSIGNEE_CHANGED = 'g_project_management_issue_assignee_changed'
      ISSUE_CLONED = 'g_project_management_issue_cloned'
      ISSUE_CLOSED = 'g_project_management_issue_closed'
      ISSUE_COMMENT_ADDED = 'g_project_management_issue_comment_added'
      ISSUE_COMMENT_EDITED = 'g_project_management_issue_comment_edited'
      ISSUE_COMMENT_REMOVED = 'g_project_management_issue_comment_removed'
      ISSUE_CREATED = 'g_project_management_issue_created'
      ISSUE_CROSS_REFERENCED = 'g_project_management_issue_cross_referenced'
      ISSUE_DESIGNS_ADDED = 'g_project_management_issue_designs_added'
      ISSUE_DESIGNS_MODIFIED = 'g_project_management_issue_designs_modified'
      ISSUE_DESIGNS_REMOVED = 'g_project_management_issue_designs_removed'
      ISSUE_DESCRIPTION_CHANGED = 'g_project_management_issue_description_changed'
      ISSUE_DUE_DATE_CHANGED = 'g_project_management_issue_due_date_changed'
      ISSUE_LABEL_CHANGED = 'g_project_management_issue_label_changed'
      ISSUE_LOCKED = 'g_project_management_issue_locked'
      ISSUE_MADE_CONFIDENTIAL = 'g_project_management_issue_made_confidential'
      ISSUE_MADE_VISIBLE = 'g_project_management_issue_made_visible'
      ISSUE_MARKED_AS_DUPLICATE = 'g_project_management_issue_marked_as_duplicate'
      ISSUE_MILESTONE_CHANGED = 'g_project_management_issue_milestone_changed'
      ISSUE_MOVED = 'g_project_management_issue_moved'
      ISSUE_REOPENED = 'g_project_management_issue_reopened'
      ISSUE_RELATED = 'g_project_management_issue_related'
      ISSUE_TIME_ESTIMATE_CHANGED = 'g_project_management_issue_time_estimate_changed'
      ISSUE_TIME_SPENT_CHANGED = 'g_project_management_issue_time_spent_changed'
      ISSUE_TITLE_CHANGED = 'g_project_management_issue_title_changed'
      ISSUE_UNLOCKED = 'g_project_management_issue_unlocked'
      ISSUE_UNRELATED = 'g_project_management_issue_unrelated'

      class << self
        def track_issue_created_action(author:, project:)
          track_unique_action(ISSUE_CREATED, author, project)
        end

        def track_issue_title_changed_action(author:, project:)
          track_unique_action(ISSUE_TITLE_CHANGED, author, project)
        end

        def track_issue_description_changed_action(author:, project:)
          track_unique_action(ISSUE_DESCRIPTION_CHANGED, author, project)
        end

        def track_issue_assignee_changed_action(author:, project:)
          track_unique_action(ISSUE_ASSIGNEE_CHANGED, author, project)
        end

        def track_issue_made_confidential_action(author:, project:)
          track_unique_action(ISSUE_MADE_CONFIDENTIAL, author, project)
        end

        def track_issue_made_visible_action(author:, project:)
          track_unique_action(ISSUE_MADE_VISIBLE, author, project)
        end

        def track_issue_closed_action(author:, project:)
          track_unique_action(ISSUE_CLOSED, author, project)
        end

        def track_issue_reopened_action(author:, project:)
          track_unique_action(ISSUE_REOPENED, author, project)
        end

        def track_issue_label_changed_action(author:, project:)
          track_unique_action(ISSUE_LABEL_CHANGED, author, project)
        end

        def track_issue_milestone_changed_action(author:, project:)
          track_unique_action(ISSUE_MILESTONE_CHANGED, author, project)
        end

        def track_issue_cross_referenced_action(author:, project:)
          track_unique_action(ISSUE_CROSS_REFERENCED, author, project)
        end

        def track_issue_moved_action(author:, project:)
          track_unique_action(ISSUE_MOVED, author, project)
        end

        def track_issue_related_action(author:, project:)
          track_unique_action(ISSUE_RELATED, author, project)
        end

        def track_issue_unrelated_action(author:, project:)
          track_unique_action(ISSUE_UNRELATED, author, project)
        end

        def track_issue_marked_as_duplicate_action(author:, project:)
          track_unique_action(ISSUE_MARKED_AS_DUPLICATE, author, project)
        end

        def track_issue_locked_action(author:, project:)
          track_unique_action(ISSUE_LOCKED, author, project)
        end

        def track_issue_unlocked_action(author:, project:)
          track_unique_action(ISSUE_UNLOCKED, author, project)
        end

        def track_issue_designs_added_action(author:, project:)
          track_unique_action(ISSUE_DESIGNS_ADDED, author, project)
        end

        def track_issue_designs_modified_action(author:, project:)
          track_unique_action(ISSUE_DESIGNS_MODIFIED, author, project)
        end

        def track_issue_designs_removed_action(author:, project:)
          track_unique_action(ISSUE_DESIGNS_REMOVED, author, project)
        end

        def track_issue_due_date_changed_action(author:, project:)
          track_unique_action(ISSUE_DUE_DATE_CHANGED, author, project)
        end

        def track_issue_time_estimate_changed_action(author:, project:)
          track_unique_action(ISSUE_TIME_ESTIMATE_CHANGED, author, project)
        end

        def track_issue_time_spent_changed_action(author:, project:)
          track_unique_action(ISSUE_TIME_SPENT_CHANGED, author, project)
        end

        def track_issue_comment_added_action(author:, project:)
          track_unique_action(ISSUE_COMMENT_ADDED, author, project)
        end

        def track_issue_comment_edited_action(author:, project:)
          track_unique_action(ISSUE_COMMENT_EDITED, author, project)
        end

        def track_issue_comment_removed_action(author:, project:)
          track_unique_action(ISSUE_COMMENT_REMOVED, author, project)
        end

        def track_issue_cloned_action(author:, project:)
          track_unique_action(ISSUE_CLONED, author, project)
        end

        private

        def track_unique_action(action, author, project)
          return unless author

          if Feature.enabled?(:route_hll_to_snowplow_phase2)
            Gitlab::Tracking.event(
              ISSUE_CATEGORY,
              action.to_s,
              project: project,
              namespace: project&.namespace,
              user: author
            )
          end

          Gitlab::UsageDataCounters::HLLRedisCounter.track_event(action, values: author.id)
        end
      end
    end
  end
end

Gitlab::UsageDataCounters::IssueActivityUniqueCounter.prepend_mod_with('Gitlab::UsageDataCounters::IssueActivityUniqueCounter')
