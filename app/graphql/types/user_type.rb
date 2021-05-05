# frozen_string_literal: true

module Types
  class UserType < ::Types::BaseObject
    graphql_name 'UserCore'
    description 'Core represention of a GitLab user.'
    implements ::Types::UserInterface

    authorize :read_user

    present_using UserPresenter

    field :saved_replies, Types::SavedReplyType.connection_type,
          null: true,
          description: 'Users saved replies.',
          authorize: :read_saved_replies,
          feature_flag: :saved_replies
  end
end
