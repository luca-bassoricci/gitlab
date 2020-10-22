# frozen_string_literal: true

module FeatureFlagIssues
  class DestroyService < IssuableLinks::DestroyService
    def permission_to_remove_relation?
      can?(current_user, :admin_feature_flag, link.feature_flag)
    end

    def create_notes
    end
  end
end
