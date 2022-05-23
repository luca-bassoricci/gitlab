# frozen_string_literal: true

class Groups::Analytics::DevopsAdoptionController < Groups::Analytics::ApplicationController
  include RedisTracking
  include ProductAnalyticsTracking

  layout 'group'

  before_action :load_group
  before_action -> { authorize_view_by_action!(:view_group_devops_adoption) }

  track_event :show, name: 'users_viewing_analytics_group_devops_adoption', destinations: [:redis_hll, :snowplow]

  def show
  end

  alias_method :tracking_namespace_source, :load_group
end
