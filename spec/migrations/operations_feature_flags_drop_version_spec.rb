# frozen_string_literal: true

require 'spec_helper'

require_migration!('operations_feature_flags_drop_version')

RSpec.describe OperationsFeatureFlagsDropVersion do
  let(:namespace) { table(:namespaces).create!(name: 'deploy_freeze', path: 'deploy_freeze') }
  let(:project) { table(:projects).create!(namespace_id: namespace.id) }

  it 'drops and restores the version column' do
    reversible_migration do |migration|
      feature_flag = table(:operations_feature_flags).create!(project_id: project.id, version: 2, active: true, name: 'foo', iid: 1)

      migration.before -> {
        expect(feature_flag.reload.version).to eq(2)
      }

      migration.after -> {
        expect { feature_flag.reload.version }.to raise_error(ActiveModel::MissingAttributeError)
      }
    end
  end
end
