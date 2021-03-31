# frozen_string_literal: true

module Resolvers
  class NotesResolver < BaseResolver
    argument :sort, Types::NoteSortEnum,
             description: 'Sort notes by this criteria.',
             required: false

    type Types::Notes::NoteType.connection_type, null: false

    def resolve(**args)
      ::NotesFinder.new(current_user, target: object, **args).execute
    end
  end
end
