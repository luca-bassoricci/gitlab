# frozen_string_literal: true

module Types
  class DeploymentStatusEnum < BaseEnum
    graphql_name 'DeploymentStatus'
    description 'All deployment statuses.'

    %i[created running success failed canceled skipped blocked].each do |status|
      value status.to_s.upcase, description: "The deployment is #{status}.", value: status
    end
  end
end
