# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User sees feature flag list', :js do
  include FeatureFlagHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, namespace: user.namespace) }

  let!(:feature_flag) { create(:operations_feature_flag, project: project, name: 'my_flag', active: false) }

  before_all do
    project.add_developer(user)
  end

  before do
    sign_in(user)
  end

  it 'user updates the status toggle' do
    visit(project_feature_flags_path(project))

    within_feature_flag_row(1) do
      status_toggle_button.click

      expect_status_toggle_button_to_be_checked
    end

    visit(project_audit_events_path(project))

    expect(page).to(
      have_text('Updated feature flag my_flag. Updated active from "false" to "true".')
    )
  end

  context 'with too many feature flags' do
    before do
      plan_limits = create(:plan_limits, :default_plan)
      plan_limits.update!(Operations::FeatureFlag.limit_name => 1)
    end

    it 'stops users from adding another' do
      visit(project_feature_flags_path(project))
      expect(page).to have_text('Feature flags limit reached (1). Delete one or more feature flags before adding new ones.')
    end
  end
end
