# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class OperationsFeatureFlagsDropVersion < ActiveRecord::Migration[6.1]
  FEATURE_FLAG_LEGACY_VERSION = 1

  def up
    # The operations_feature_flags table is small enough that we can disable this cop.
    # rubocop:disable Migration/RemoveColumn
    remove_column(:operations_feature_flags, :version)
    # rubocop:enable Migration/RemoveColumn
  end

  def down
    add_column(:operations_feature_flags, :version, :smallint, default: FEATURE_FLAG_LEGACY_VERSION, allow_null: false)
  end
end
