# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::OpenIssuesCountService, :use_clean_rails_memory_store_caching do
  let(:project) { create(:project) }
  let(:banned_user) { create(:user, :banned) }

  subject { described_class.new(project) }

  it_behaves_like 'a counter caching service'

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
          expect(described_class.new(project).count).to eq(1)
        end

        it 'uses open_public_issues_without_banned_count cache key' do
          expect(described_class.new(project).cache_key_name).to eq('open_public_issues_without_banned_count')
        end
      end

      context 'when user is provided' do
        let(:user) { create(:user) }

        context 'when user can read confidential issues' do
          before do
            project.add_reporter(user)
          end

          it 'includes confidential issues and does not include issues created by banned users in count' do
            expect(described_class.new(project, user).count).to eq(2)
          end

          it 'uses open_issues_without_banned_count cache key' do
            expect(described_class.new(project, user).cache_key_name).to eq('open_issues_without_banned_count')
          end
        end

        context 'when user cannot read confidential issues' do
          before do
            project.add_guest(user)
          end

          it 'does not include confidential issues or issues created by banned users in count' do
            expect(described_class.new(project, user).count).to eq(1)
          end

          it 'uses open_public_issues_without_banned_count cache key' do
            expect(described_class.new(project, user).cache_key_name).to eq('open_public_issues_without_banned_count')
          end
        end

        context 'when user is an admin', :enable_admin_mode do
          let(:admin) { create(:user, :admin) }

          it 'includes confidential issues and issues created by banned users in count' do
            expect(described_class.new(project, admin).count).to eq(3)
          end

          it 'uses open_issues_including_banned_count cache key' do
            expect(described_class.new(project, admin).cache_key_name).to eq('open_issues_including_banned_count')
          end
        end
      end
    end

    describe '#refresh_cache', :aggregate_failures do
      before do
        create(:issue, :opened, project: project)
        create(:issue, :opened, confidential: true, project: project)
        create(:issue, :opened, author: banned_user, project: project)
      end

      context 'when cache is empty' do
        it 'refreshes cache keys correctly' do
          subject.refresh_cache

          expect(Rails.cache.read(subject.cache_key(described_class::PUBLIC_COUNT_WITHOUT_BANNED_KEY))).to eq(1)
          expect(Rails.cache.read(subject.cache_key(described_class::TOTAL_COUNT_WITHOUT_BANNED_KEY))).to eq(2)
          expect(Rails.cache.read(subject.cache_key(described_class::TOTAL_COUNT_KEY))).to eq(3)
        end
      end

      context 'when cache is outdated' do
        before do
          subject.refresh_cache
        end

        it 'refreshes cache keys correctly' do
          create(:issue, :opened, project: project)
          create(:issue, :opened, confidential: true, project: project)
          create(:issue, :opened, author: banned_user, project: project)

          subject.refresh_cache

          expect(Rails.cache.read(subject.cache_key(described_class::PUBLIC_COUNT_WITHOUT_BANNED_KEY))).to eq(2)
          expect(Rails.cache.read(subject.cache_key(described_class::TOTAL_COUNT_WITHOUT_BANNED_KEY))).to eq(4)
          expect(Rails.cache.read(subject.cache_key(described_class::TOTAL_COUNT_KEY))).to eq(6)
        end
      end
    end
  end
end
