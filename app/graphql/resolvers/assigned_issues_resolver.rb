# frozen_string_literal: true

module Resolvers
  class AssignedIssuesResolver < UserIssuesResolverBase
    type ::Types::IssueType.connection_type, null: true

    def user_role
      :assignee
    end
  end
end
