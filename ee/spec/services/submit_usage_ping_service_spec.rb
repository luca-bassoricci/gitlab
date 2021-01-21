# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SubmitUsagePingService do
  include StubRequests
  include UsageDataHelpers
  include EE::GeoHelpers

  let(:with_dev_ops_score_params) { { dev_ops_score: { some_data: 'value' } } }

  context 'when usage ping is enabled on a geo secondary' do
    before do
      stub_usage_data_connections
      stub_application_setting(usage_ping_enabled: true)
      stub_secondary_node
      stub_response(body: with_dev_ops_score_params)
    end

    it 'does not save auto devops report data' do
      expect { subject.execute }
        .not_to change { DevOpsReport::Metric.count }
    end

    it 'does not create a raw_usage_data record' do
      expect { subject.execute }.not_to change(RawUsageData, :count)
    end
  end

  def stub_response(body:, status: 201)
    stub_full_request(SubmitUsagePingService::STAGING_URL, method: :post)
      .to_return(
        headers: { 'Content-Type' => 'application/json' },
        body: body.to_json,
        status: status
      )
  end
end
