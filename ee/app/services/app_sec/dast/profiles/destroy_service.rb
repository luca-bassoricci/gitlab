# frozen_string_literal: true

module AppSec
  module Dast
    module Profiles
      class DestroyService < BaseContainerService
        def execute
          return unauthorized unless allowed?
          return ServiceResponse.error(message: 'Profile parameter missing') unless dast_profile
          return ServiceResponse.error(message: 'Profile failed to delete') unless dast_profile.destroy

          ServiceResponse.success(payload: dast_profile)
        end

        private

        def allowed?
          can?(current_user, :create_on_demand_dast_scan, container)
        end

        def unauthorized
          ServiceResponse.error(
            message: 'You are not authorized to update this profile',
            http_status: 403
          )
        end

        def dast_profile
          params[:dast_profile]
        end
      end
    end
  end
end
