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
        google_api_client.enable_artifacts_registry(gcp_project_id)
        google_api_client.enable_cloud_build(gcp_project_id)
      end
      branch_name = "cloud-run-#{SecureRandom.hex(8)}"
      target_branch = project.default_branch

      project.repository.add_branch(current_user, branch_name, target_branch)

      gitlab_ci_yml = begin
                        get_gitlab_ci_yml # this can fail on the very first commit
                      rescue StandardError
                        nil
                      end

      commit_attrs = {
        commit_message: 'Enable Cloud Run deployments',
        branch_name: branch_name,
        start_branch: branch_name,
        actions: [
          { action: gitlab_ci_yml.present? ? 'update' : 'create',
            file_path: '.gitlab-ci.yml',
            content: generate_cloud_run_pipeline(gitlab_ci_yml) }
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

  def get_gitlab_ci_yml
    gitlab_ci_yml = project.repository.gitlab_ci_yml_for(project.repository.root_ref_sha)
    YAML.safe_load(gitlab_ci_yml || '{}')
  end

  def generate_cloud_run_pipeline(gitlab_ci_yml)
    stages = gitlab_ci_yml['stages'] || []
    gitlab_ci_yml['stages'] = (stages + %w[build test deploy]).uniq

    includes = gitlab_ci_yml['include'] || []
    includes = Array.wrap(includes)
    includes << { 'template' => 'Jobs/Build.gitlab-ci.yml' }
    includes << { 'template' => 'Jobs/Test.gitlab-ci.yml' }
    includes << { 'remote' => 'https://gitlab.com/gitlab-org/incubation-engineering/five-minute-production/library/-/raw/main/gcp/cloud-run.gitlab-ci.yml' }
    gitlab_ci_yml['include'] = includes.uniq

    gitlab_ci_yml.to_yaml
  end
end
