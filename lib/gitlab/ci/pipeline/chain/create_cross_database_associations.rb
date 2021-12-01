# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        class CreateCrossDatabaseAssociations < Chain::Base
          def perform!
            create_deployments!
          end

          def break?
            false # to be overridden in EE
          end

          private

          def create_deployments!
            return unless pipeline.create_deployment_in_separate_transaction?

            pipeline.stages.map(&:statuses).flatten.map(&method(:save_deployment))
          end

          def save_deployment(build)
            return unless build.instance_of?(::Ci::Build) && build.persisted_environment.present?

            build.deployment.save
          end
        end
      end
    end
  end
end

Gitlab::Ci::Pipeline::Chain::CreateCrossDatabaseAssociations.prepend_mod_with('Gitlab::Ci::Pipeline::Chain::CreateCrossDatabaseAssociations')
