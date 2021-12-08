# frozen_string_literal: true

require 'spec_helper'

require_migration!

RSpec.describe UpdateStateEnumInSprintsWhereStateEnumIsTwo, :migration do
  let(:migration) { described_class.new }
  let(:namespaces) { table(:namespaces) }
  let(:sprints) { table(:sprints) }
  let(:iterations_cadences) { table(:iterations_cadences) }

  let!(:group) { namespaces.create!(name: 'foo', path: 'foo') }
  let!(:cadence_1) { iterations_cadences.create!(group_id: group.id, title: "cadence 1", start_date: Date.new(2021, 11, 1)) }
  let!(:cadence_2) { iterations_cadences.create!(group_id: group.id, title: "cadence 2", start_date: Date.new(2021, 11, 1)) }

  let!(:sprint_1) { sprints.create!(id: 1, state_enum: 1, group_id: group.id, iterations_cadence_id: cadence_1.id, start_date: Date.new(2021, 11, 1), due_date: Date.new(2021, 11, 5), iid: 1, title: 'a' ) }
  let!(:sprint_2) { sprints.create!(id: 2, state_enum: 2, group_id: group.id, iterations_cadence_id: cadence_1.id, start_date: Date.new(2021, 12, 1), due_date: Date.new(2021, 12, 5), iid: 2, title: 'b') }
  let!(:sprint_3) { sprints.create!(id: 3, state_enum: 3, group_id: group.id, iterations_cadence_id: cadence_2.id, start_date: Date.new(2021, 11, 15), due_date: Date.new(2021, 11, 20), iid: 3, title: 'c') }
  let!(:sprint_4) { sprints.create!(id: 4, state_enum: 2, group_id: group.id, iterations_cadence_id: cadence_2.id, start_date: Date.new(2021, 12, 1), due_date: Date.new(2021, 12, 5), iid: 4, title: 'd') }

  it 'updates all state enum whose value is 2 to 0 then back to 2', :aggregate_failures do
    migration.up

    expect(ordered_state_enums).to eq([1, 0, 3, 0])

    migration.down

    expect(ordered_state_enums).to eq([1, 2, 3, 2])
  end

  def ordered_state_enums
    sprints.order(id: :asc).map(&:state_enum)
  end
end
