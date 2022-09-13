# frozen_string_literal: true

module Projects
  module Settings
    class MobileDevopsController < Projects::ApplicationController
      layout 'project_settings'

      before_action :authorize_admin_project!
      feature_category :mobile_devops
      urgency :low

      def show
      end
    end
  end
end
