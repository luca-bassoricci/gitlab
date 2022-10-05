# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuditEventsHelper do
  using RSpec::Parameterized::TableSyntax

  def setup_permission(model, permission, current_user, has_permission)
    allow(helper).to receive(:current_user).and_return(current_user)
    allow(helper)
      .to receive(:can?)
      .with(current_user, permission, model)
      .and_return(has_permission)
  end

  describe '#admin_audit_event_tokens' do
    it 'returns the available tokens' do
      available_tokens = [
        { type: AuditEventsHelper::FILTER_TOKEN_TYPES[:user] },
        { type: AuditEventsHelper::FILTER_TOKEN_TYPES[:group] },
        { type: AuditEventsHelper::FILTER_TOKEN_TYPES[:project] }
      ]
      expect(admin_audit_event_tokens).to eq(available_tokens)
    end
  end

  describe '#group_audit_event_tokens' do
    let(:group_id) { 1 }

    it 'returns the available tokens' do
      available_tokens = [{ type: AuditEventsHelper::FILTER_TOKEN_TYPES[:member], group_id: group_id }]
      expect(group_audit_event_tokens(group_id)).to eq(available_tokens)
    end
  end

  describe '#project_audit_event_tokens' do
    let(:project_path) { '/abc' }

    it 'returns the available tokens' do
      available_tokens = [{ type: AuditEventsHelper::FILTER_TOKEN_TYPES[:member], project_path: project_path }]
      expect(project_audit_event_tokens(project_path)).to eq(available_tokens)
    end
  end

  describe '#export_url' do
    subject { export_url }

    it { is_expected.to eq('http://test.host/admin/audit_log_reports.csv') }
  end

  describe '#show_streams_for_group?' do
    let_it_be(:group) { build(:group) }
    let_it_be(:subgroup) { build(:group, :nested) }
    let_it_be(:current_user) { build(:user) }

    it 'returns false if the group is a subgroup' do
      expect(helper.show_streams_for_group?(subgroup)).to eq(false)
    end

    where(has_permission?: [true, false])

    with_them do
      before do
        setup_permission(group, :admin_external_audit_events, current_user, has_permission?)
      end

      it "returns #{params[:has_permission?]}" do
        expect(helper.show_streams_for_group?(group)).to eq(has_permission?)
      end
    end
  end

  describe '#view_only_own_group_events?' do
    let_it_be(:group) { build(:group) }
    let_it_be(:current_user) { build(:user) }

    context 'when the user has permission to view other events' do
      before do
        setup_permission(group, :admin_group, current_user, true)
      end

      it "returns false" do
        expect(helper.view_only_own_group_events?(group)).to eq(false)
      end
    end

    context 'when the user does not have permission' do
      before do
        setup_permission(group, :admin_group, current_user, false)
      end

      it "returns true" do
        expect(helper.view_only_own_group_events?(group)).to eq(true)
      end
    end
  end

  describe '#view_only_own_project_events?' do
    let_it_be(:project) { build(:project) }
    let_it_be(:current_user) { build(:user) }

    context 'when the user has permission to view other events' do
      before do
        setup_permission(project, :admin_project, current_user, true)
      end

      it "returns false" do
        expect(helper.view_only_own_project_events?(project)).to eq(false)
      end
    end

    context 'when the user does not have permission' do
      before do
        setup_permission(project, :admin_project, current_user, false)
      end

      it "returns true" do
        expect(helper.view_only_own_project_events?(project)).to eq(true)
      end
    end
  end

  describe '#filter_view_only_own_events_token_values' do
    let_it_be(:current_user) { build(:user, username: 'abc') }

    it 'returns an array with a member token when view_only is true' do
      allow(helper).to receive(:current_user).and_return(current_user)

      expect(helper.filter_view_only_own_events_token_values(true)).to eq(
        [{ type: AuditEventsHelper::FILTER_TOKEN_TYPES[:member], data: '@abc' }]
      )
    end

    it 'returns an empty array when view_only is false' do
      expect(helper.filter_view_only_own_events_token_values(false)).to eq([])
    end
  end
end
