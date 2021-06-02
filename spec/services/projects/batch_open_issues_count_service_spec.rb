# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::BatchOpenIssuesCountService do
  let!(:project_1) { create(:project) }
  let!(:project_2) { create(:project) }

  let_it_be(:banned_user) { create(:user, :banned) }

  let(:subject) { described_class.new([project_1, project_2]) }
  let(:count_service) { subject.count_service }

  describe '#refresh_cache', :use_clean_rails_memory_store_caching do
    before do
      create(:issue, project: project_1)
      create(:issue, project: project_1, confidential: true)
      create(:issue, :opened, author: banned_user, project: project_1)

      create(:issue, project: project_2)
      create(:issue, project: project_2, confidential: true)
      create(:issue, :opened, author: banned_user, project: project_2)
    end

    context 'when cache is clean' do
      it 'refreshes cache keys correctly', :aggregate_failures do
        # It does not update total issues cache
        count_service.new(project_1).refresh_cache
        count_service.new(project_2).refresh_cache

        expect(Rails.cache.read(count_service.new(project_1))).to eq(nil)
        expect(Rails.cache.read(count_service.new(project_2))).to eq(nil)

        expect(Rails.cache.read(count_service.new(project_1).cache_key(count_service::PUBLIC_COUNT_WITHOUT_HIDDEN_KEY))).to eq(1)
        expect(Rails.cache.read(count_service.new(project_1).cache_key(count_service::TOTAL_COUNT_WITHOUT_HIDDEN_KEY))).to eq(2)
        expect(Rails.cache.read(count_service.new(project_1).cache_key(count_service::TOTAL_COUNT_KEY))).to eq(3)

        expect(Rails.cache.read(count_service.new(project_2).cache_key(count_service::PUBLIC_COUNT_WITHOUT_HIDDEN_KEY))).to eq(1)
        expect(Rails.cache.read(count_service.new(project_2).cache_key(count_service::TOTAL_COUNT_WITHOUT_HIDDEN_KEY))).to eq(2)
        expect(Rails.cache.read(count_service.new(project_2).cache_key(count_service::TOTAL_COUNT_KEY))).to eq(3)
      end
    end

    context 'when issues count is already cached' do
      before do
        create(:issue, project: project_2)
        subject.refresh_cache
      end

      it 'does update cache again' do
        expect(Rails.cache).not_to receive(:write)

        subject.refresh_cache
      end
    end
  end
end
