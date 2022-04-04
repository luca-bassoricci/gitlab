# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::BackgroundMigration::Adapt::AutovacuumActiveOnTable do
  include Database::DatabaseHelpers

  let(:connection) { Gitlab::Database.database_base_models[:main].connection }

  around do |example|
    Gitlab::Database::SharedModel.using_connection(connection) do
      example.run
    end
  end

  describe '#evaluate' do
    subject { described_class.new(context).evaluate }

    before do
      swapout_view_for_table(:postgres_autovacuum_activity)
    end

    let(:context) { Gitlab::Database::BackgroundMigration::Adapt::Context.new(tables) }
    let(:tables) { [table] }
    let(:table) { 'users' }

    context 'without autovacuum activity' do
      it 'returns Normal signal' do
        expect(subject).to be_a(Gitlab::Database::BackgroundMigration::Adapt::NormalSignal)
      end

      it 'remembers the indicator class' do
        expect(subject.indicator_class).to eq(described_class)
      end
    end

    context 'with autovacuum activity' do
      before do
        create(:postgres_autovacuum_activity, table: table, table_identifier: "public.#{table}")
      end

      it 'returns Stop signal' do
        expect(subject).to be_a(Gitlab::Database::BackgroundMigration::Adapt::StopSignal)
      end

      it 'explains why' do
        expect(subject.reason).to include('autovacuum running on: table public.users')
      end

      it 'remembers the indicator class' do
        expect(subject.indicator_class).to eq(described_class)
      end
    end
  end
end
