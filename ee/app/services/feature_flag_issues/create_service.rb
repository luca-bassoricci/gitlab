# frozen_string_literal: true

module FeatureFlagIssues
  class CreateService < IssuableLinks::CreateService
    extend ::Gitlab::Utils::Override

    override :execute
    def execute
      unless current_user.can?(:admin_feature_flags_issue_links, issuable.project)
        return error('Unauthorized request', 401)
      end

      super
    end

    def previous_related_issuables
      @related_issues ||= issuable.issues.to_a
    end

    def linkable_issuables(issues)
      Ability.issues_readable_by_user(issues, current_user)
    end

    def relate_issuables(referenced_issue)
      attrs = { feature_flag_id: issuable.id, issue: referenced_issue }
      ::FeatureFlagIssue.create(attrs)
    end

    def self.create_link_from_note(note, current_user)
      return unless note.for_issue?
      return unless Feature.enabled?(:feature_flag_contextual_issue, note.project)

      # Finding a feature flag reference in the note.
      # Currently, there is a limitation to create up-to one link per note due to performance reason.
      feature_flag = note.all_references(current_user).feature_flags.first
      return unless feature_flag

      params = { issuable_references: [note.noteable.to_reference] }
      new(feature_flag, current_user, params).execute
    end
  end
end
