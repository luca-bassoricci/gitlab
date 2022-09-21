# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Start trial from external site with confirmation', :saas, :js do
  let_it_be(:glm_params) do
    { glm_source: 'some_source', glm_content: 'some_content' }
  end

  before do
    # saas flow
    stub_application_setting(
      require_admin_approval_after_user_signup: false,
      send_user_confirmation_email: true
    )

    stub_feature_flags(
      about_your_company_registration_flow: true,
      arkose_labs_signup_challenge: false,
      soft_email_confirmation: false
    )

    # The groups_and_projects_controller (on `click_on 'Create project'`) is over
    # the query limit threshold, so we have to adjust it.
    # https://gitlab.com/gitlab-org/gitlab/-/issues/338737
    stub_const('Gitlab::QueryLimiting::Transaction::THRESHOLD', 142)
    stub_request(:post, "#{EE::SUBSCRIPTIONS_URL}/trials")
  end

  it 'passes glm parameters from trial registration page all the way until user is onboarded' do
    user = build_stubbed(:user)
    visit new_trial_registration_path(glm_params)

    fill_in 'new_user_first_name', with: user.first_name
    fill_in 'new_user_last_name', with: user.last_name
    fill_in 'new_user_username', with: user.username
    fill_in 'new_user_email', with: user.email
    fill_in 'new_user_password', with: user.password
    click_button 'Continue'

    token = User.find_by(email: user.email).confirmation_token
    visit user_confirmation_path(confirmation_token: token)

    fill_in 'user_password', with: user.password
    click_button 'Sign in'

    select 'Software Developer', from: 'user_role'
    choose 'My company or team'
    click_button 'Continue'

    expect(Gitlab::SubscriptionPortal::Client)
      .to receive(:generate_trial)
      .with(hash_including(glm_params))
      .and_call_original

    fill_in 'company_name', with: 'Company name'
    select '1 - 99', from: 'company_size'
    select 'Australia', from: 'country'
    click_button 'Continue'

    fill_in 'group_name', with: 'Group name'
    fill_in 'blank_project_name', with: 'Project name'
    click_button 'Create project'

    expect(page).to have_content('Get started with GitLab')
    expect(page).to have_content('Creating your onboarding experience...')
  end
end
