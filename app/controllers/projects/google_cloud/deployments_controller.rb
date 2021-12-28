# frozen_string_literal: true

class Projects::GoogleCloud::DeploymentsController < Projects::GoogleCloud::BaseController
  before_action :validate_gcp_token!

  def cloud_run
    gcp_project_ids = get_gcp_project_ids

    if gcp_project_ids.empty?
      flash[:alert] = "No GCP projects found. Configure a service account or GCP_PROJECT_ID ci variable."
      redirect_to project_google_cloud_index_path(project)
    else
      google_api_client = GoogleApi::CloudPlatform::Client.new(token_in_session, nil)
      gcp_project_ids.each do |gcp_project_id|
        google_api_client.enable_cloud_run(gcp_project_id)
      end
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
                  ), notice: _('Google Cloud Run enabled')
    end
  rescue Google::Apis::ClientError => error
    handle_gcp_error(error, project)
  end

  def cloud_storage
    render json: get_gcp_project_ids
  end

  private

  def get_gcp_project_ids
    project.variables.filter { |var| var.key == 'GCP_PROJECT_ID' }.map { |var| var.value }
  end

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
