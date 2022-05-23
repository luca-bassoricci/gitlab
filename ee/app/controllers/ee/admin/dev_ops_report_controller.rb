# frozen_string_literal: true

module EE
  module Admin
    module DevOpsReportController
      extend ActiveSupport::Concern

      prepended do
        # blocked by https://gitlab.com/gitlab-org/gitlab/-/issues/362274#note_955902819
        # track_event :show, name: 'i_analytics_dev_ops_adoption',
        #  conditions: -> { show_adoption? && params[:tab] != 'devops-score' }, destinations: [:redis_hll, :snowplow]
      end

      def should_track_devops_score?
        !show_adoption? || params[:tab] == 'devops-score'
      end

      def show_adoption?
        ::License.feature_available?(:devops_adoption)
      end
    end
  end
end
