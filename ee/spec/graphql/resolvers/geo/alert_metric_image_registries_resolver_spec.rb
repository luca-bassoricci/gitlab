# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Geo::AlertMetricImageRegistriesResolver do
  it_behaves_like 'a Geo registries resolver', :geo_alert_metric_image_registry
end
