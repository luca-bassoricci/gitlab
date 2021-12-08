# frozen_string_literal: true
class GroupsWithTemplatesFinder
  def initialize(group_id = nil)
    @group_id = group_id
  end

  def execute
    if ::Gitlab::CurrentSettings.should_check_namespace_plan?
      groups = extended_group_search
      simple_group_search(groups)
    else
      simple_group_search(Group.all)
    end
  end

  private

  attr_reader :group_id

  def extended_group_search
    # We're adding an extra query that will be removed once we remove the feature flag in https://gitlab.com/gitlab-org/gitlab/-/issues/339439
    groups = if Feature.enabled?(:linear_groups_template_finder_extended_group_search_ancestors_scopes, current_group, default_enabled: :yaml)
               Group.with_project_templates.self_and_ancestors
             else
               Gitlab::ObjectHierarchy
                 .new(Group.with_project_templates)
                 .base_and_ancestors
             end

    groups.with_feature_available_in_plan(:group_project_templates).self_and_descendants
  end

  def simple_group_search(groups)
    groups = group_id ? groups.find_by(id: group_id)&.self_and_ancestors : groups # rubocop: disable CodeReuse/ActiveRecord
    return Group.none unless groups

    groups.with_project_templates
  end

  # This method will be removed https://gitlab.com/gitlab-org/gitlab/-/issues/339439
  def current_group
    Group.find_by(id: group_id) # rubocop:disable CodeReuse/ActiveRecord
  end
end
