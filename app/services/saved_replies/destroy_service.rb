# frozen_string_literal: true

module SavedReplies
  class DestroyService < BaseContainerService
    def execute(saved_reply)
      saved_reply.destroy
    end
  end
end
