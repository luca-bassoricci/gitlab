# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::Analytics::DevopsAdoptionController do
  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create :group }

  before do
    sign_in(current_user)

    stub_licensed_features(group_level_devops_adoption: true)
  end

  describe 'GET show' do
    subject do
      get group_analytics_devops_adoption_path(group)
    end

    context 'when user is not authorized to view devops adoption analytics' do
      before do
        allow(Ability).to receive(:allowed?).and_call_original
        expect(Ability).to receive(:allowed?).with(current_user, :read_group, group).and_return(true)
        expect(Ability).to receive(:allowed?).with(current_user, :view_group_devops_adoption, group).and_return(false)
      end

      it 'renders 403, forbidden error' do
        subject

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context 'when user is an auditor' do
      let(:current_user) { create(:user, :auditor) }

      it 'allows access' do
        subject

        expect(response).to have_gitlab_http_status(:success)
      end
    end

    context 'when the user is a group maintainer', :snowplow do
      before do
        group.add_maintainer(current_user)
      end

      it 'renders the devops adoption page' do
        subject

        expect(response).to render_template :show
      end

      context 'when the feature is not available' do
        before do
          stub_licensed_features(group_level_devops_adoption: false)
        end

        it 'renders forbidden' do
          subject

          expect(response).to have_gitlab_http_status(:forbidden)
        end
      end

      it 'tracks devops_adoption usage Snowplow event' do
        subject

        expect_snowplow_event(
          category: 'Groups::Analytics::DevopsAdoptionController',
          action: 'users_viewing_analytics_group_devops_adoption',
          namespace: group,
          user: current_user
        )
      end

      it 'tracks devops_adoption usage Redis event' do
        expect(Gitlab::UsageDataCounters::HLLRedisCounter)
          .to receive(:track_event).with('users_viewing_analytics_group_devops_adoption', values: kind_of(String))

        subject
      end

      context 'when FF route_hll_to_snowplow_phase2 is disable' do
        before do
          stub_feature_flags(route_hll_to_snowplow_phase2: false)
        end

        it 'doesnt track Snowplow event' do
          subject

          expect_no_snowplow_event
        end
      end
    end
  end
end
