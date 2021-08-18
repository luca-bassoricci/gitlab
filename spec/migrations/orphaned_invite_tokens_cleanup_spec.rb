# frozen_string_literal: true

require 'spec_helper'
require_migration! 'orphaned_invite_tokens_cleanup'

RSpec.describe OrphanedInviteTokensCleanup, :migration do
  def create_member(**extra_attributes)
    defaults = {
      access_level: 10,
      source_id: 1,
      source_type: "Project",
      notification_level: 0,
      type: 'ProjectMember'
    }

    table(:members).create!(defaults.merge(extra_attributes))
  end

  describe '#up', :aggregate_failures do
    it 'removes invite tokens for accepted records with invite_accepted_at < created_at' do
      record1 = create_member(invite_token: 'foo', invite_accepted_at: 1.day.ago, created_at: 1.hour.ago)
      record2 = create_member(invite_token: 'foo2', invite_accepted_at: nil, created_at: 1.hour.ago)
      record3 = create_member(invite_token: 'foo3', invite_accepted_at: 1.day.ago, created_at: 1.year.ago)

      migrate!

      expect(table(:members).find(record1.id).invite_token).to eq nil
      expect(table(:members).find(record2.id).invite_token).to eq 'foo2'
      expect(table(:members).find(record3.id).invite_token).to eq 'foo3'
    end
  end
end
