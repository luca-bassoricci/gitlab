# frozen_string_literal: true

class Projects::GoogleCloud::ServiceAccountsController < Projects::GoogleCloud::BaseController
  before_action :validate_gcp_token!

  def index
    @google_cloud_path = project_google_cloud_index_path(project)
    google_api_client = GoogleApi::CloudPlatform::Client.new(token_in_session, nil)
    gcp_projects = google_api_client.list_projects

    if gcp_projects.empty?
      @js_data = { screen: 'no_gcp_projects' }.to_json
      render status: :unauthorized, template: 'projects/google_cloud/errors/no_gcp_projects'
    else
      @js_data = {
        screen: 'service_accounts_form',
        gcpProjects: gcp_projects,
        environments: project.environments,
        cancelPath: project_google_cloud_index_path(project)
      }.to_json
    end
  rescue Google::Apis::ClientError => error
    handle_gcp_error(error, project)
  end

  def create
    google_api_client = GoogleApi::CloudPlatform::Client.new(token_in_session, nil)
    service_accounts_service = GoogleCloud::ServiceAccountsService.new(project)
    gcp_project = params[:gcp_project]
    environment_name = params[:environment]
    environment = project.environments.find_by(name: environment_name)
    is_environment_protected = environment ? environment.protected? : false
    generated_name = "GitLab :: #{@project.name} :: #{environment_name}"
    generated_desc = "GitLab generated service account for project '#{@project.name}' and environment '#{environment_name}'"

    service_account = google_api_client.create_service_account(gcp_project, generated_name, generated_desc)
    service_account_key = google_api_client.create_service_account_key(gcp_project, service_account.unique_id)
    google_api_client.grant_service_account_roles(gcp_project, service_account.email)

    service_accounts_service.add_for_project(
      environment_name,
      service_account.project_id,
      service_account.to_json,
      service_account_key.to_json,
      is_environment_protected
    )

    redirect_to project_google_cloud_index_path(project), notice: _('Service account generated successfully')
  rescue Google::Apis::ClientError, Google::Apis::ServerError, Google::Apis::AuthorizationError => error
    handle_gcp_error(error, project)
  end

  private
end
