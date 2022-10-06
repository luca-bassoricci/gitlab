# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::AlertMetricImageRegistryFinder do
  it_behaves_like 'a framework registry finder', :geo_alert_metric_image_registry
end
