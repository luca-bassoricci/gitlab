# frozen_string_literal: true

class UpdateStateEnumInSprintsWhereStateEnumIsTwo < Gitlab::Database::Migration[1.0]
  def up
    execute(<<~SQL)
      UPDATE sprints SET state_enum=0 WHERE state_enum=2;
    SQL
  end

  def down
    execute(<<~SQL)
      UPDATE sprints SET state_enum=2 WHERE state_enum=0;
    SQL
  end
end
