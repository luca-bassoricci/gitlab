# frozen_string_literal: true

class CreateSavedReplies < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table_with_constraints :saved_replies do |t|
      t.references :user, index: true, foreign_key: { on_delete: :cascade }, null: false
      t.text :title
      t.text :note

      t.text_limit :title, 128
      t.text_limit :note, 1024
    end
  end
end
