# frozen_string_literal: true

module SavedReplies
  class CreateService < BaseContainerService
    def execute
      saved_reply = ::SavedReplies::BuildService.new(
        container: current_user,
        current_user: current_user,
        params: params
      ).execute

      saved_reply.save

      saved_reply
    end
  end
end
