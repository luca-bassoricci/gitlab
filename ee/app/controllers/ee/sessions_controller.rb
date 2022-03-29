# frozen_string_literal: true

module EE
  module SessionsController
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      include ArkoseLabsCSP

      before_action :gitlab_geo_logout, only: [:destroy]
      before_action only: [:new] do
        push_frontend_feature_flag(:arkose_labs_login_challenge, default_enabled: :yaml)
      end
    end

    override :new
    def new
      return super if signed_in?

      if ::Gitlab::Geo.secondary_with_primary?
        current_node_uri = URI(GeoNode.current_node_url)
        state = geo_login_state.encode
        redirect_to oauth_geo_auth_url(host: current_node_uri.host, port: current_node_uri.port, state: state)
      else
        if ::Feature.enabled?(:arkose_labs_login_challenge)
          @arkose_labs_public_key ||= ENV['ARKOSE_LABS_PUBLIC_KEY'] # rubocop:disable Gitlab/ModuleWithInstanceVariables
        end

        super
      end
    end

    protected

    override :auth_options
    def auth_options
      if params[:trial]
        { scope: resource_name, recall: "trial_registrations#new" }
      else
        super
      end
    end

    private

    def gitlab_geo_logout
      return unless ::Gitlab::Geo.secondary?

      # The @geo_logout_state instance variable is used within
      # ApplicationController#after_sign_out_path_for to redirect
      # the user to the logout URL on the primary after sign out
      # on the secondary.
      @geo_logout_state = geo_logout_state.encode # rubocop:disable Gitlab/ModuleWithInstanceVariables
    end

    def geo_login_state
      ::Gitlab::Geo::Oauth::LoginState.new(return_to: sanitize_redirect(geo_return_to_after_login))
    end

    def geo_logout_state
      ::Gitlab::Geo::Oauth::LogoutState.new(token: session[:access_token], return_to: geo_return_to_after_logout)
    end

    def geo_return_to_after_login
      stored_redirect_uri || ::Gitlab::Utils.append_path(root_url, session[:user_return_to].to_s)
    end

    def geo_return_to_after_logout
      safe_redirect_path_for_url(request.referer)
    end

    override :log_failed_login
    def log_failed_login
      login = request.filtered_parameters.dig('user', 'login')
      audit_event_service = ::AuditEventService.new(login, nil)
      audit_event_service.for_failed_login.unauth_security_event

      super
    end

    override :arkose_labs_enabled?
    def arkose_labs_enabled?
      ::Feature.enabled?(:arkose_labs_login_challenge, default_enabled: :yaml) && request.headers[::SessionsController::CAPTCHA_HEADER]
    end

    override :check_captcha
    def check_captcha
      if ::Feature.enabled?(:arkose_labs_login_challenge, default_enabled: :yaml)
        check_arkose_captcha
      else
        super
      end
    end

    def check_arkose_captcha
      return unless user_params[:password].present?
      return unless params[:arkose_labs_token].present?

      user = ::User.find_by_username(user_params[:login])

      return unless user.present?

      if Arkose::UserVerificationService.new(session_token: params[:arkose_labs_token], userid: user.id).execute
        increment_successful_login_captcha_counter
      else
        increment_failed_login_captcha_counter

        self.resource = resource_class.new
        flash[:alert] = 'Login failed. Please retry from your primary device and network'
        flash.delete :recaptcha_error

        respond_with_navigational(resource) { render :new }
      end
    end
  end
end
