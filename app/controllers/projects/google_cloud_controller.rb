# frozen_string_literal: true

class Projects::GoogleCloudController < Projects::GoogleCloud::BaseController
  def index
    @js_data = {
      screen: 'home',
      serviceAccounts: GoogleCloud::ServiceAccountsService.new(project).find_for_project,
      createServiceAccountUrl: project_google_cloud_service_accounts_path(project),
      emptyIllustrationUrl: ActionController::Base.helpers.image_path('illustrations/pipelines_empty.svg')
    }.to_json
  end

  def revoke
    uri = URI('https://oauth2.googleapis.com/revoke')
    Net::HTTP.post_form(uri, 'token' => token_in_session)
    session.delete(GoogleApi::CloudPlatform::Client.session_key_for_token)
    redirect_to project_google_cloud_index_path(project), notice: _('Google OAuth2 token revoked')
  end

  private

  def token_in_session
    session[GoogleApi::CloudPlatform::Client.session_key_for_token]
  end
end
