# frozen_string_literal: true
module Types
  module Repository
    # rubocop: disable Graphql/AuthorizeTypes
    # This is presented through `Repository` that has its own authorization
    class BlobType < BaseObject
      present_using BlobPresenter

      graphql_name 'RepositoryBlob'

      field :code_owners, [Types::UserType], null: true,
            description: 'List of code owners for the blob.',
            calls_gitaly: true
    end
  end
end
