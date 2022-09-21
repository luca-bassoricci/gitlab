# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddSecureFilesMetadata < Gitlab::Database::Migration[2.0]
  def change
    add_column :ci_secure_files, :metadata, :jsonb
    add_column :ci_secure_files, :expires_at, :datetime_with_timezone
  end
end
