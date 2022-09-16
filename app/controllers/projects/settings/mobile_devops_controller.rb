# frozen_string_literal: true

module Projects
  module Settings
    class MobileDevopsController < Projects::ApplicationController
      layout 'project_settings'

      before_action :authorize_read_project!
      before_action :mobile_devops_settings_enabled!

      feature_category :mobile_devops
      urgency :low

      def show
      end

      private

      def mobile_devops_settings_enabled!
        render_404 unless Feature.enabled?(:mobile_devops_settings, project)
      end
    end
  end
end
