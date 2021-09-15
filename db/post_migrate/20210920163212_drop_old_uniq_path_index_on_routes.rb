# frozen_string_literal: true

class DropOldUniqPathIndexOnRoutes < Gitlab::Database::Migration[1.0]
  disable_ddl_transaction!

  class MigrationRoute < ApplicationRecord
    include EachBatch

    self.table_name = 'routes'
  end

  def up
    remove_concurrent_index_by_name :routes, 'index_routes_on_path'
  end

  def down
    Route.where(source_type: 'Namespaces::ProjectNamespace').each_batch do |batch|
      batch.delete_all
    end

    add_concurrent_index :routes, 'LOWER(path)', unique: true, name: 'index_routes_on_path'
  end
end
