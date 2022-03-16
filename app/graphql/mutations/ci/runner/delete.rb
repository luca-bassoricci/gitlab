# frozen_string_literal: true

module Mutations
  module Ci
    module Runner
      class Delete < BaseMutation
        graphql_name 'RunnerDelete'

        authorize :delete_runner

        RunnerID = ::Types::GlobalIDType[::Ci::Runner]

        argument :id, RunnerID,
                 required: true,
                 description: 'ID of the runner to delete.'

        def resolve(id:, **runner_attrs)
          runner = authorized_find!(id)

          ::Ci::Runners::UnregisterRunnerService.new(runner, current_user).execute

          { errors: runner.errors.full_messages }
        end

        def find_object(id)
          # TODO: remove this line when the compatibility layer is removed
          # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
          id = RunnerID.coerce_isolated_input(id)

          GitlabSchema.find_by_gid(id)
        end
      end
    end
  end
end
