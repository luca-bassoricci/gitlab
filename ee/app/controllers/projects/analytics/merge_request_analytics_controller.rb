# frozen_string_literal: true

class Projects::Analytics::MergeRequestAnalyticsController < Projects::ApplicationController
  include ProductAnalyticsTracking
  include RedisTracking

  before_action :authorize_read_project_merge_request_analytics!

  track_event :show, name: 'p_analytics_merge_request', destinations: [:redis_hll, :snowplow]

  feature_category :value_stream_management

  def show
  end

  private

  def tracking_namespace_source
    project&.namespace
  end
end
