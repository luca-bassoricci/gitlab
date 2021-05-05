# frozen_string_literal: true

module SavedReplies
  class UpdateService < BaseContainerService
    def execute(saved_reply)
      saved_reply.update(params)
    end
  end
end
