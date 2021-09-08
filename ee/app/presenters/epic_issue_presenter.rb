# frozen_string_literal: true

class EpicIssuePresenter < Gitlab::View::Presenter::Delegated
  delegator_override :issue
  presents :issue, ::EpicIssue

  def group_epic_issue_path(current_user)
    return unless can_admin_issue_link?(current_user)

    url_builder.group_epic_issue_path(issue.epic.group, issue.epic.iid, issue.epic_issue_id)
  end

  private

  def can_admin_issue_link?(current_user)
    Ability.allowed?(current_user, :admin_epic_issue, issue) && Ability.allowed?(current_user, :admin_epic, issue.epic)
  end
end
