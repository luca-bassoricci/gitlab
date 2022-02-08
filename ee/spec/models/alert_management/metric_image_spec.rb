# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::MetricImage do
  let_it_be(:factory_name) { :alert_metric_image }
  let_it_be(:license_feature) { :alert_metric_upload }

  subject { build(factory_name) }

  describe 'associations' do
    it { is_expected.to belong_to(:alert) }
  end

  it_behaves_like 'a metric image model'
end
