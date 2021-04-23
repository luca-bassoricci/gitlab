# frozen_string_literal: true

# This shared_example requires the following variables:
# - user
# - cache_key, array
# - params, hash
RSpec.shared_examples 'a finder with cached count by state' do
  subject { described_class.new(user, params).count_by_state }

  context 'when `cached_issuable_count_by_state` feature flag is disabled' do
    before do
      stub_feature_flags(cached_issuable_count_by_state: false)
    end

    it 'does not cache the counts result' do
      subject
      expect(Rails.cache).not_to receive(:fetch).with(cache_key, expires_in: 1.hour)
    end
  end

  context 'when `cached_issuable_count_by_state` feature flag is enabled' do
    before do
      stub_feature_flags(cached_issuable_count_by_state: true)
    end

    it 'caches the counts result if no bar filters are present' do
      allow(Rails.cache).to receive(:fetch).and_return({ all: 5, opened: 3, closed: 2 })

      subject
      expect(Rails.cache).to have_received(:fetch).with(cache_key, expires_in: 1.hour)
    end

    context 'when bar filters are present' do
      before do
        params[:author_id] = user.id
      end

      it 'does not cache the counts result' do
        subject
        expect(Rails.cache).not_to receive(:fetch).with(cache_key, expires_in: 1.hour)
      end
    end
  end
end
