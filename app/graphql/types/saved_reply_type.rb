# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class SavedReplyType < BaseObject
    graphql_name 'SavedReply'

    field :id, GraphQL::ID_TYPE, null: false,
          description: 'ID of the saved reply.'
    field :title, GraphQL::ID_TYPE, null: false,
          description: 'Title of the saved reply.'
    field :note, GraphQL::ID_TYPE, null: false,
          description: 'Full note text of the saved reply.'
  end
end
