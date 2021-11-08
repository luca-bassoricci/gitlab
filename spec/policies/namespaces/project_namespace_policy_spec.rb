# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NamespacePolicy do
  let_it_be(:parent) { create(:user_namespace) }
  let_it_be(:namespace) { create(:project_namespace, parent: parent) }

  let(:permissions) do
    [:owner_access, :create_projects, :admin_namespace, :read_namespace,
     :read_statistics, :transfer_projects, :create_package_settings,
     :read_package_settings, :create_jira_connect_subscription]
  end

  subject { described_class.new(current_user, namespace) }

  context 'with no user' do
    let_it_be(:current_user) { nil }

    it { is_expected.to be_disallowed(*permissions) }
  end

  context 'regular user' do
    let_it_be(:current_user) { create(:user) }

    it { is_expected.to be_disallowed(*permissions) }
  end

  context 'parent owner' do
    let_it_be(:current_user) { parent.owner }

    it { is_expected.to be_disallowed(*permissions) }
  end

  context 'admin' do
    let_it_be(:current_user) { create(:admin) }

    context 'when admin mode is enabled', :enable_admin_mode do
      it { is_expected.to be_allowed(*permissions) }
    end

    context 'when admin mode is disabled' do
      it { is_expected.to be_disallowed(*permissions) }
    end
  end
end
