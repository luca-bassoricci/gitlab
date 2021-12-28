# frozen_string_literal: true

class Projects::GoogleCloud::BaseController < Projects::ApplicationController
  feature_category :five_minute_production_app

  before_action :admin_project_google_cloud!
  before_action :google_oauth2_enabled!
  before_action :feature_flag_enabled!

  private

  def admin_project_google_cloud!
    access_denied! unless can?(current_user, :admin_project_google_cloud, project)
  end

  def google_oauth2_enabled!
    config = Gitlab::Auth::OAuth::Provider.config_for('google_oauth2')
    if config.app_id.blank? || config.app_secret.blank?
      access_denied! 'This GitLab instance not configured for Google Oauth2.'
    end
  end

  def feature_flag_enabled!
    access_denied! unless Feature.enabled?(:incubation_5mp_google_cloud, project)
  end

  def token_in_session
    session[GoogleApi::CloudPlatform::Client.session_key_for_token]
  end

  def expires_at_in_session
    session[GoogleApi::CloudPlatform::Client.session_key_for_expires_at]
  end

  def validate_gcp_token!
    is_token_valid = GoogleApi::CloudPlatform::Client.new(token_in_session, nil)
                                                     .validate_token(expires_at_in_session)

    return if is_token_valid

    return_url = project_google_cloud_index_path(project)
    state = generate_session_key_redirect(request.url, return_url)
    @authorize_url = GoogleApi::CloudPlatform::Client.new(nil,
                                                          callback_google_api_auth_url,
                                                          state: state).authorize_url
    redirect_to @authorize_url
  end

  def generate_session_key_redirect(uri, error_uri)
    GoogleApi::CloudPlatform::Client.new_session_key_for_redirect_uri do |key|
      session[key] = uri
      session[:error_uri] = error_uri
    end
  end

  def handle_gcp_error(error, project)
    message = error.body
    @js_data = { screen: 'gcp_error' }

    if message.include?('Cloud Resource Manager API has not been used in project')
      @js_data['title'] = 'GCP Misconfiguration - CloudResourceManager API not enabled'
      @js_data['description'] = <<-DESCRIPTION
        The Google Cloud Platform project associated with this GitLab instance
        is not configured to use the Cloud Resource Manager API.
        This can be enabled by your administrator.
        Please contact your GitLab administrator to resolve this issue.
        If you are the admin, you may use the link below to enable the API.
      DESCRIPTION
      @js_data['primaryButtonText'] = 'Enable Cloud Resource Manager API'
      @js_data['primaryButtonLink'] = URI.extract(message).first

    elsif message.include?('Identity and Access Management (IAM) API has not been used in project')
      @js_data['title'] = 'GCP Misconfiguration - Identity and Access Management API not enabled'
      @js_data['description'] = <<-DESCRIPTION
        The Google Cloud Platform project associated with this GitLab instance
        is not configured to use the Identity and Access Management API.
        This can be enabled by your administrator.
        Please contact your GitLab administrator to resolve this issue.
        If you are the admin, you may use the link below to enable the API.
      DESCRIPTION
      @js_data['primaryButtonText'] = 'Enable Identity and Access Management API'
      @js_data['primaryButtonLink'] = URI.extract(message).first

    elsif message.include?('Service Usage API has not been used in project')
      @js_data['title'] = 'GCP Misconfiguration - Service Usage API not enabled'
      @js_data['description'] = <<-DESCRIPTION
        The Google Cloud Platform project associated with this GitLab instance
        is not configured to use the Service Usage API.
        This can be enabled by your administrator.
        Please contact your GitLab administrator to resolve this issue.
        If you are the admin, you may use the link below to enable the API.
      DESCRIPTION
      @js_data['primaryButtonText'] = 'Enable Service Usage API'
      @js_data['primaryButtonLink'] = URI.extract(message).first

    elsif message.include?('Billing must be enabled')
      @js_data['title'] = 'GCP Misconfiguration - Billing account required'
      @js_data['description'] = <<-DESCRIPTION
        A billing account needs to be associated with your Google Cloud Platform projects.
        If you are the Google Cloud Platform admin, please log in to the Google Cloud Console
        and associate a billing account with your projects.
      DESCRIPTION
      @js_data['error'] = message
      @js_data['primaryButtonText'] = 'Configure billing account'
      gcp_project_id = JSON.parse(error.body)['error']['details'][1]['metadata']['project']
      @js_data['primaryButtonLink'] = "https://console.cloud.google.com/billing?project=#{gcp_project_id}"
    end

    @js_data = @js_data.to_json
    Gitlab::ErrorTracking.track_exception(error, project_id: project.id)
    render status: :unauthorized, template: 'projects/google_cloud/errors/gcp_error'
  end
end
