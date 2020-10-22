# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User reopens a merge requests', :js do
  let(:project) { create(:project, :public, :repository) }
  let!(:merge_request) { create(:closed_merge_request, source_project: project, target_project: project) }
  let(:user) { create(:user) }

  before do
    project.add_maintainer(user)
    sign_in(user)

    visit(merge_request_path(merge_request))
  end

  it 'reopens a merge request' do
    find('.js-issuable-close-dropdown .dropdown-toggle').click

    click_link('Reopen merge request', match: :first)

    wait_for_requests

    page.within('.status-box') do
      expect(page).to have_content('Open')
    end
  end
end
