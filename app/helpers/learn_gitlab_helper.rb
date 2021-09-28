# frozen_string_literal: true

module LearnGitlabHelper
  def learn_gitlab_enabled?(project)
    return false unless current_user

    learn_gitlab_onboarding_available?(project)
  end

  def onboarding_actions_data(project)
    attributes = onboarding_progress(project).attributes.symbolize_keys

    action_urls.to_h do |action, url|
      [
        action,
        url: url,
        completed: attributes[OnboardingProgress.column_name(action)].present?,
        svg: image_path("learn_gitlab/#{action}.svg")
      ]
    end
  end

  def onboarding_sections_data
    {
      workspace: {
        svg: image_path("learn_gitlab/section_workspace.svg")
      },
      plan: {
        svg: image_path("learn_gitlab/section_plan.svg")
      },
      deploy: {
        svg: image_path("learn_gitlab/section_deploy.svg")
      }
    }
  end

  def learn_gitlab_data(project)
    {
      actions: onboarding_actions_data(project).to_json,
      sections: onboarding_sections_data.to_json
    }
  end

  def learn_gitlab_onboarding_available?(project)
    OnboardingProgress.onboarding?(project.namespace) &&
      LearnGitlab::Project.new(current_user).available?
  end

  private

  def action_urls
    LearnGitlab::Onboarding::ACTION_ISSUE_IDS.transform_values { |id| project_issue_url(learn_gitlab_project, id) }
      .merge(LearnGitlab::Onboarding::ACTION_DOC_URLS)
  end

  def learn_gitlab_project
    @learn_gitlab_project ||= LearnGitlab::Project.new(current_user).project
  end

  def onboarding_progress(project)
    OnboardingProgress.find_by(namespace: project.namespace) # rubocop: disable CodeReuse/ActiveRecord
  end
end
