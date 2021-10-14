# frozen_string_literal: true

module Mutations
  module AppSec::Fuzzing::Coverage
    module Corpus
      class Delete < BaseMutation
        graphql_name 'CorpusDelete'

        argument :id, ::Types::GlobalIDType[::AppSec::Fuzzing::Coverage::Corpus],
                  required: true,
                  description: 'ID of the corpus.'

        authorize :destroy_coverage_fuzzing_corpus

        def resolve(**args)
          corpus = authorized_find!(id)

          corpus.destroy!
        end

        def find_object(id)
          id = Types::GlobalIDType[Project].coerce_isolated_input(id)
          corpus = GitlabSchema.find_by_gid(id)

          response = destroy_service.new(
            current_user,
            params: {
              corpus: corpus
            }
          ).execute

          { errors: Array.wrap(response.message) }
        end

        private

        def destroy_service
          ::AppSec::Fuzzing::Coverage::Corpuses::DestroyService
        end
      end
    end
  end
end