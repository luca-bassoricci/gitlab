# frozen_string_literal: true

# Add support for automatic background recreation of mounted versions after the file is stored.
module Versions
  module BackgroundRecreate
    extend ActiveSupport::Concern
    include MountsHelper

    included do
      include AfterCommitQueue
      after_save do
        background_recreate(changed_mounts)
      end
    end

    def background_recreate(mount_points = [])
      return unless mount_points.any?

      run_after_commit do
        mount_points.each { |mount| send(mount).try(:schedule_background_recreate) } # rubocop:disable GitlabSecurity/PublicSend
      end
    end
  end
end
