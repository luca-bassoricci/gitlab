# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequests::HandleAssigneesChangeService do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user) }
  let_it_be(:assignee) { create(:user) }
  let_it_be_with_reload(:merge_request) { create(:merge_request, author: user, source_project: project, assignees: [assignee]) }
  let_it_be(:old_assignees) { create_list(:user, 3) }

  let(:options) { {} }
  let(:service) { described_class.new(project: project, current_user: user) }

  before_all do
    project.add_maintainer(user)
    project.add_developer(assignee)

    old_assignees.each do |old_assignee|
      project.add_developer(old_assignee)
    end
  end

  describe '#async_execute' do
    def async_execute
      service.async_execute(merge_request, old_assignees, options)
    end

    it 'performs MergeRequests::HandleAssigneesChangeWorker asynchronously' do
      expect(MergeRequests::HandleAssigneesChangeWorker)
        .to receive(:perform_async)
        .with(
          merge_request.id,
          user.id,
          old_assignees.map(&:id),
          options
        )

      async_execute
    end
  end

  describe '#execute' do
    def execute
      service.execute(merge_request, old_assignees, options)
    end

    let(:note) { merge_request.notes.system.last }
    let(:removed_note) { "unassigned #{old_assignees.map(&:to_reference).to_sentence}" }

    context 'when unassigning all users' do
      before do
        merge_request.update!(assignee_ids: [])
      end

      it 'creates assignee note' do
        execute

        expect(note).not_to be_nil
        expect(note.note).to eq removed_note
      end
    end

    it 'creates assignee note' do
      execute

      expect(note).not_to be_nil
      expect(note.note).to include "assigned to #{assignee.to_reference} and #{removed_note}"
    end

    it 'sends email notifications to old and new assignees', :mailer, :sidekiq_inline do
      perform_enqueued_jobs do
        execute
      end

      should_email(assignee)
      old_assignees.each do |old_assignee|
        should_email(old_assignee)
      end
    end

    it 'creates pending todo for assignee' do
      execute

      todo = assignee.todos.last

      expect(todo).to be_pending
    end

    it 'removes attention requested state' do
      expect(MergeRequests::RemoveAttentionRequestedService).to receive(:new)
        .with(project: project, current_user: user, merge_request: merge_request, user: user)
        .and_call_original

      execute
    end

    it 'updates attention requested by of assignee' do
      execute

      expect(merge_request.find_assignee(assignee).updated_state_by).to eq(user)
    end

    it 'tracks users assigned event' do
      expect(Gitlab::UsageDataCounters::MergeRequestActivityUniqueCounter)
        .to receive(:track_users_assigned_to_mr).once.with(users: [assignee])

      execute
    end

    it 'tracks assignees changed event' do
      expect(Gitlab::UsageDataCounters::MergeRequestActivityUniqueCounter)
        .to receive(:track_assignees_changed_action).once.with(user: user)

      execute
    end

    context 'when execute_hooks option is set to true' do
      let(:options) { { execute_hooks: true } }

      it 'executes hooks and integrations' do
        expect(merge_request.project).to receive(:execute_hooks).with(anything, :merge_request_hooks)
        expect(merge_request.project).to receive(:execute_integrations).with(anything, :merge_request_hooks)
        expect(service).to receive(:enqueue_jira_connect_messages_for).with(merge_request)

        execute
      end
    end
  end
end
