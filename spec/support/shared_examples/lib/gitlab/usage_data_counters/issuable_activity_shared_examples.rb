# frozen_string_literal: true

RSpec.shared_examples 'a daily tracked issuable event' do
  before do
    stub_application_setting(usage_ping_enabled: true)
  end

  def count_unique(date_from: 1.minute.ago, date_to: 1.minute.from_now)
    Gitlab::UsageDataCounters::HLLRedisCounter.unique_events(event_names: action, start_date: date_from, end_date: date_to)
  end

  specify do
    aggregate_failures do
      expect(track_action(author: user1)).to be_truthy
      expect(track_action(author: user1)).to be_truthy
      expect(track_action(author: user2)).to be_truthy
      expect(count_unique).to eq(2)
    end
  end

  context 'when author not present', :snowplow do
    let(:author) { nil }

    it 'does not track edit actions' do
      expect(track_action(author: nil)).to be_nil
    end

    it 'does not track Snowplow action' do
      expect_no_snowplow_event
    end
  end
end

RSpec.shared_examples 'does not track when feature flag is disabled' do |feature_flag|
  context "when feature flag #{feature_flag} is disabled" do
    it 'does not track action' do
      stub_feature_flags(feature_flag => false)

      expect(track_action(author: user1)).to be_nil
    end
  end
end
