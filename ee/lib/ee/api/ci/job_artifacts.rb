# frozen_string_literal: true

module EE
  module API
    module Ci
      module JobArtifacts
        extend ActiveSupport::Concern

        prepended do
          helpers do
            def authorize_download_artifacts!
              super
              check_cross_project_pipelines_feature!
            end

            def check_cross_project_pipelines_feature!
              return unless job_token_authentication?

              if cross_project_request && !user_project.licensed_feature_available?(:cross_project_pipelines)
                not_found!('Project')
              end
            end

            def cross_project_request
              user_project != current_authenticated_job.project
            end
          end
        end
      end
    end
  end
end
