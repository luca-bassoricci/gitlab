# frozen_string_literal: true

class AddCiPipelinesTitle < Gitlab::Database::Migration[2.0]
  enable_lock_retries!

  INDEX_NAME = 'index_ci_pipeline_details_on_title_include_project_id'

  def up
    create_table :ci_pipeline_details, id: false do |t|
      t.references :project, null: false, foreign_key: { on_delete: :cascade }
      t.references :pipeline, null: false, index: false, foreign_key: { to_table: :ci_pipelines, on_delete: :cascade }
      t.text :title, null: false, limit: 50

      t.index [:pipeline_id, :title], name: 'index_ci_pipeline_details_on_pipeline_id_title'
    end

    execute <<-SQL
      CREATE INDEX #{INDEX_NAME} ON ci_pipeline_details
        USING btree (title)
        INCLUDE (project_id)
    SQL
  end

  def down
    drop_table :ci_pipeline_details
  end
end
