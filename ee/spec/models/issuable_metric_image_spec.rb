# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssuableMetricImage do
  let_it_be(:factory_name) { :issuable_metric_image }
  let_it_be(:license_feature) { :incident_metric_upload }

  subject { build(factory_name) }

  describe 'associations' do
    it { is_expected.to belong_to(:issue) }
  end

  it_behaves_like 'a metric image model'
end
