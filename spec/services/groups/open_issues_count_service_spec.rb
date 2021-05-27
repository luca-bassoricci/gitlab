# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::OpenIssuesCountService, :use_clean_rails_memory_store_caching do
  let_it_be(:group) { create(:group, :public)}
  let_it_be(:project) { create(:project, :public, namespace: group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:banned_user) { create(:user, :banned) }
  let_it_be(:admin) { create(:user, :admin) }

  subject { described_class.new(group, user) }

  describe '#relation_for_count' do
    before do
      allow(IssuesFinder).to receive(:new).and_call_original
    end

    it 'uses the IssuesFinder to scope issues' do
      expect(IssuesFinder)
        .to receive(:new)
        .with(user, group_id: group.id, state: 'opened', non_archived: true, include_subgroups: true, public_only: true)

      subject.count
    end
  end

  describe '#count' do
    context 'returns different issue counts depending on user' do
      before do
        create(:issue, :opened, project: project)
        create(:issue, :opened, confidential: true,  project: project)
        create(:issue, :opened, author: banned_user, project: project)
        subject.refresh_cache
      end

      context 'when user is nil' do
        it 'does not include confidential issues or issues created by banned users in count' do
          expect(described_class.new(group).count).to eq(1)
        end

        it 'uses group_public_open_issues_without_banned_count cache key' do
          expect(described_class.new(group).cache_key_name).to eq('group_public_open_issues_without_banned_count')
        end
      end

      context 'when user is provided' do
        let(:user) { create(:user) }

        context 'when user can read confidential issues' do
          before do
            group.add_reporter(user)
          end

          it 'includes confidential issues and does not include issues created by banned users in count' do
            expect(described_class.new(group, user).count).to eq(2)
          end

          it 'uses group_total_open_issues_without_banned_count cache key' do
            expect(described_class.new(group, user).cache_key_name).to eq('group_total_open_issues_without_banned_count')
          end
        end

        context 'when user cannot read confidential issues' do
          before do
            group.add_guest(user)
          end

          it 'does not include confidential issues or issues created by banned users in count' do
            expect(described_class.new(group, user).count).to eq(1)
          end

          it 'uses group_public_open_issues_without_banned_count cache key' do
            expect(described_class.new(group, user).cache_key_name).to eq('group_public_open_issues_without_banned_count')
          end
        end

        context 'when user is an admin', :enable_admin_mode do
          it 'includes confidential issues and issues created by banned users in count' do
            expect(described_class.new(group, admin).count).to eq(3)
          end

          it 'uses open_issues_including_banned_count cache key' do
            expect(described_class.new(group, admin).cache_key_name).to eq('group_total_open_issues_count')
          end
        end
      end
    end
  end

  describe '#clear_all_cache_keys' do
    it 'calls `Rails.cache.delete` with the correct keys' do
      expect(Rails.cache).to receive(:delete)
        .with(['groups', 'open_issues_count_service', 1, group.id, described_class::PUBLIC_COUNT_WITHOUT_BANNED_KEY])
      expect(Rails.cache).to receive(:delete)
        .with(['groups', 'open_issues_count_service', 1, group.id, described_class::TOTAL_COUNT_KEY])
      expect(Rails.cache).to receive(:delete)
        .with(['groups', 'open_issues_count_service', 1, group.id, described_class::TOTAL_COUNT_WITHOUT_BANNED_KEY])

      subject.clear_all_cache_keys
    end
  end
end
