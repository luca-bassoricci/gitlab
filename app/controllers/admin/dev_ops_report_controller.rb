# frozen_string_literal: true

class Admin::DevOpsReportController < Admin::ApplicationController
  include ProductAnalyticsTracking

  helper_method :show_adoption?

  # blocked by https://gitlab.com/gitlab-org/gitlab/-/issues/362274#note_955902819
  # track_event :show, name: 'i_analytics_dev_ops_score', conditions: -> { should_track_devops_score? },
  #   destinations: [:redis_hll, :snowplow]

  feature_category :devops_reports

  urgency :low

  # rubocop: disable CodeReuse/ActiveRecord
  def show
    @metric = DevOpsReport::Metric.order(:created_at).last&.present
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def show_adoption?
    false
  end

  def should_track_devops_score?
    true
  end
end

Admin::DevOpsReportController.prepend_mod_with('Admin::DevOpsReportController')
