# frozen_string_literal: true

module Mutations
  module MergeRequests
    class SetMilestone < Base
      graphql_name 'MergeRequestSetMilestone'

      argument :milestone_id,
               ::Types::GlobalIDType[::Milestone],
               required: :nullable,
               loads: Types::MilestoneType,
               description: <<~DESC
                 Milestone to assign to the merge request. Milestone is removed if null.
               DESC

      def resolve(project_path:, iid:, milestone:)
        merge_request = authorized_find!(project_path: project_path, iid: iid)
        project = merge_request.project

        ::MergeRequests::UpdateService.new(project: project, current_user: current_user, params: { milestone: milestone })
          .execute(merge_request)

        {
          merge_request: merge_request,
          errors: errors_on_object(merge_request)
        }
      end
    end
  end
end
