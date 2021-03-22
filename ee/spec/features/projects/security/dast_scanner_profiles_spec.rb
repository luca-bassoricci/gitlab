# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User sees Scanner profile', :js do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :repository) }
  let(:profile_form_path) {new_project_security_configuration_dast_profiles_dast_scanner_profile_path(project)}
  let(:profile_library_path) { project_security_configuration_dast_profiles_path(project) }

  before_all do
    project.add_developer(user)
  end

  before do
    sign_in(user)
  end

  # context 'when feature is not available' do
  #   before do
  #     stub_licensed_features(security_on_demand_scans: false)
  #   end

  #   it 'renders a 404' do
  #     visit_new_profile_page
  #     expect(page).to have_gitlab_http_status(:not_found)
  #   end
  # end

  context 'when feature is available' do
    before do
      stub_licensed_features(security_on_demand_scans: true)
      visit(profile_form_path)
    end

    it 'shows the form' do
      # expect(page).to have_gitlab_http_status(:ok)
      expect(page).to have_content("New scanner profile")
    end

    it 'on submit' do
      fill_in_profile_form
      expect(current_path).to eq(profile_library_path)
    end

    it 'on cancel' do
      click_button 'Cancel'
      expect(current_path).to eq(profile_library_path)
    end
  end

  def fill_in_profile_form
    fill_in 'profile_name', with: "hello"
    fill_in 'spider_timeout', with: "1"
    fill_in 'target_timeout', with: "2"
    click_button 'Save profile'
    wait_for_requests
  end
end
