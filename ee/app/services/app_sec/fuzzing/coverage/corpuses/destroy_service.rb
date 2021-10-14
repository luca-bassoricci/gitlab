# frozen_string_literal: true

module AppSec::Fuzzing::Coverage
  module Corpuses
    class DestroyService < BaseService
      def execute()
        project = corpus.project

        unless project
          return ServiceResponse.error(
            message: 'Project not found',
            http_status: 404)
        end

        unless current_user.can?(:delete_corpus, project)
          return ServiceResponse.error(
            message: 'You dont have access to delete this corpus',
            http_status: 405)
        end


        unless corpus.destroy
          return ServiceResponse.error(
            message: corpus.full_message,
            http_status: 400
          )
        end

        ServiceResponse.success(message: 'Corpus was deleted')
      rescue KeyError => err
        ServiceResponse.error(message: err.message.capitalize)
      end

      private

      def unlock_artifacts(branch_name)
        Ci::RefDeleteUnlockArtifactsWorker.perform_async(project.id, current_user.id, "#{::Gitlab::Git::BRANCH_REF_PREFIX}#{branch_name}")
      end

      def corpus
        @corpus ||= params.fetch(:corpus)
      end
    end
  end
end
