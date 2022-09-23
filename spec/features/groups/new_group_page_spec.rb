# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'New group page', :js do
  let(:user)  { create(:user) }
  let(:group) { create(:group) }

  before do
    sign_in(user)
  end

  describe 'new top level group alert' do
    context 'when a user visits the new group page' do
      it 'shows the new top level group alert' do
        visit new_group_path(anchor: 'create-group-pane')

        expect(page).to have_selector('[data-testid="new-top-level-alert"]')
      end
    end

    context 'when a user visits the new sub group page' do
      let(:parent_group) { create(:group) }

      it 'does not show the new top level group alert' do
        visit new_group_path(parent_id: parent_group.id, anchor: 'create-group-pane')

        expect(page).not_to have_selector('[data-testid="new-top-level-alert"]')
      end
    end
  end
end
