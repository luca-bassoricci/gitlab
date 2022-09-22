# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SaaS registration from an invite', :js, :saas, :saas_registration do
  let(:new_user) { build(:user, name: 'Invited User') }

  it 'registers the user and sends them to the group activity page' do
    group = create(:group, name: 'Test Group')

    registers_from_invite(group)

    expect_to_see_welcome_form_without_join_project_question

    fill_in_welcome_form
    click_on 'Get started!'

    expect_to_be_on_activity_page_for(group)
  end

  def registers_from_invite(group)
    invitation = create(:group_member, :invited, :developer, invite_email: new_user.email, source: group)

    visit invite_path(invitation.raw_invite_token, invite_type: Emails::Members::INITIAL_INVITE)

    fill_in 'First name', with: new_user.first_name
    fill_in 'Last name', with: new_user.last_name
    fill_in 'Username', with: new_user.username
    fill_in 'Email', with: new_user.email
    fill_in 'Password', with: new_user.password

    wait_for_all_requests

    click_button 'Register'
  end

  def fill_in_welcome_form
    select 'Software Developer', from: 'user_role'
    select 'A different reason', from: 'user_registration_objective'
    fill_in 'Why are you signing up? (optional)', with: 'My reason'
  end

  def expect_to_see_welcome_form_without_join_project_question
    expect(page).to have_content('Welcome to GitLab, Invited!')
    expect(page).not_to have_content('What would you like to do?')
  end

  def expect_to_be_on_activity_page_for(group)
    expect(page).to have_current_path(activity_group_path(group), ignore_query: true)
    expect(page).to have_content('You have been granted Developer access to group Test Group')
  end
end
