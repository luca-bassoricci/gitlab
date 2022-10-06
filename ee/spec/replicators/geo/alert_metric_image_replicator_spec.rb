# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::AlertMetricImageReplicator do
  let(:model_record) { build(:alert_metric_image) }

  include_examples 'a blob replicator'
  include_examples 'a verifiable replicator'
end
