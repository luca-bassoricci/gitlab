# frozen_string_literal: true

class Projects::GoogleCloud::DeploymentsController < Projects::GoogleCloud::BaseController
  def cloud_run
    branch_name = "cloud-run-#{SecureRandom.hex(8)}"
    pipeline_content = generate_cloud_run_pipeline
    target_branch = project.default_branch

    project.repository.add_branch(current_user, branch_name, target_branch)

    commit_attrs = {
      commit_message: 'Enable Cloud Run deployments',
      branch_name: branch_name,
      start_branch: branch_name,
      actions: [
        { action: 'update',
          file_path: '.gitlab-ci.yml',
          content: pipeline_content }
      ]
    }

    ::Files::MultiService.new(@project, current_user, commit_attrs).execute

    redirect_to project_new_merge_request_path(
                  project,
                  merge_request: {
                    title: 'Enable Cloud Run deployments',
                    description: 'This merge request will enable Cloud Run deployments.',
                    source_project_id: project.id,
                    target_project_id: project.id,
                    source_branch: branch_name,
                    target_branch: target_branch
                  }
                )
  end

  def cloud_storage
    render json: { "foo" => "bar" }
  end

  private

  def generate_cloud_run_pipeline
    <<-YAML
stages:
  - deploy

"Deploy :: Cloud Run":
  stage: deploy
  script:
    - echo "MOCK Deploying to Cloud Run"
YAML
  end
end
