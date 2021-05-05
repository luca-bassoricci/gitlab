# frozen_string_literal: true

module SavedReplies
  class BuildService < BaseContainerService
    def execute
      Users::SavedReply.new(params.merge(user: current_user))
    end
  end
end
