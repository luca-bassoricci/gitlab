# frozen_string_literal: true

class AddPathUniqIndexForProjectNamespaceRoutes < Gitlab::Database::Migration[1.0]
  disable_ddl_transaction!

  def up
    add_concurrent_index :routes, 'LOWER(path)', unique: true, where: "source_type in ('Namespace', 'Namespaces::ProjectNamespace')",
      name: 'index_routes_on_path_for_project_namespace'
  end

  def down
    remove_concurrent_index_by_name :routes, 'index_routes_on_path_for_project_namespace'
  end
end
