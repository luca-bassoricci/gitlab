# frozen_string_literal: true

class AddGroupEmailVisibilityDisabled < Gitlab::Database::Migration[1.0]
  def change
    add_column :namespaces, :email_visibility_disabled, :boolean
  end
end
