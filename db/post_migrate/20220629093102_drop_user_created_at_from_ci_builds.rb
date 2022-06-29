# frozen_string_literal: true

class DropUserCreatedAtFromCiBuilds < Gitlab::Database::Migration[2.0]
  disable_ddl_transaction!

  INDEX_NAME = 'index_ci_builds_on_user_id_and_created_at_and_type_eq_ci_build'

  def up
    remove_concurrent_index_by_name :ci_builds, INDEX_NAME
  end

  # rubocop:disable Migration/PreventIndexCreation
  def down
    add_concurrent_index :ci_builds,
      [:user_id, :created_at],
      where: "((type)::text = 'Ci::Build'::text)",
      name: INDEX_NAME
  end
  # rubocop:enable Migration/PreventIndexCreation
end
