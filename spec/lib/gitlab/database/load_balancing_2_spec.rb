# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::LoadBalancing do

  # For such an important module like LoadBalancing, full mocking is not
  # enough. This section implements some integration tests to test a full flow
  # of the load balancer.
  # - A real model with a table backed behind is defined
  # - The load balancing module is set up for this module only, as to prevent
  # breaking other tests. The replica configuration is cloned from the test
  # configuraiton.
  # - In each test, we listen to the SQL queries (via sql.active_record
  # instrumentation) while triggering real queries from the defined model.
  # - We assert the desinations (replica/primary) of the queries in order.
  describe 'LoadBalancing integration tests', :db_load_balancing_new, :delete do
    before(:all) do
      ActiveRecord::Schema.define do
        create_table :load_balancing_test, force: true do |t|
          t.string :name, null: true
        end

      end

    end

    after(:all) do
      # ActiveRecord::Schema.define do
      #   drop_table :load_balancing_test, force: true
      # end
    end

    let(:model) do
      Class.new(ApplicationRecord) do
        self.table_name = "load_balancing_test"
      end
    end

    before do
      model.singleton_class.prepend ::Gitlab::Database::LoadBalancing::ActiveRecordProxy
    end

    where(:queries, :include_transaction, :expected_results) do
      [
        [-> { model.first }, false, [:replica]]
      ]
    end

    with_them do
      it 'redirects queries to the right roles' do

        allow(Gitlab::Application).to receive(:configure)
        allow(Gitlab::Database::LoadBalancing).to receive(:enable?).at_least(:once).and_return(true)
        db_host = Gitlab::Database.main.config['host']
        allow(Gitlab::Database::LoadBalancing).to receive(:hosts).and_return([db_host, db_host])

        allow(Gitlab::Cluster::LifecycleEvents).to receive(:in_clustered_environment?).and_return(true)

        load Rails.root.join('config/initializers/load_balancing.rb')

        roles = []

        subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |event|
          payload = event.payload

          assert =
            if payload[:name] == 'SCHEMA'
              false
            elsif payload[:name] == 'SQL' # Custom query
              true
            else
              keywords = %w[load_balancing_test]
              keywords += %w[begin commit] if include_transaction
              keywords.any? { |keyword| payload[:sql].downcase.include?(keyword) }
            end

          if assert
            db_role = ::Gitlab::Database::LoadBalancing.db_role_for_connection(payload[:connection])
            roles << db_role
          end
        end

        # Should replace with something that triggers on_fork AR callback.
        # Process.fork?
        ActiveRecord::ConnectionAdapters::PoolConfig.discard_pools!


        # Manually trigger callback
        Gitlab::Cluster::LifecycleEvents.do_worker_start

        self.instance_exec(&queries)

        expect(roles).to eql(expected_results)
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
      end
    end
  end
end

