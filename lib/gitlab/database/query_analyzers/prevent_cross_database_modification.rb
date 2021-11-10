# frozen_string_literal: true

module Gitlab
  module Database
    module QueryAnalyzers
      class PreventCrossDatabaseModification < Database::QueryAnalyzers::Base
        CrossDatabaseModificationAcrossUnsupportedTablesError = Class.new(StandardError)

        def self.allow_cross_database_modification?
          Thread.current[:prevent_cross_database_modification_allowed]
        end

        def self.allow_cross_database_modification=(value)
          Thread.current[:prevent_cross_database_modification_allowed] = value
        end

        def self.with_allow_cross_database_modification(value, &blk)
          previous = self.allow_cross_database_modification?
          self.allow_cross_database_modification = value

          yield
        ensure
          self.allow_cross_database_modification = previous
        end

        # This method will allow cross database modifications within the block
        # Example:
        #
        # allow_cross_database_modification_within_transaction(url: 'url-to-an-issue') do
        #   create(:build) # inserts ci_build and project record in one transaction
        # end
        def self.allow_cross_database_modification_within_transaction(url:, &blk)
          self.with_allow_cross_database_modification(true, &blk)
        end

        # This method will prevent cross database modifications within the block
        # if it was allowed previously
        def self.with_cross_database_modification_prevented(&blk)
          self.with_allow_cross_database_modification(false, &blk)
        end

        def self.begin!
          super

          context.merge!({
            transaction_depth_by_db: Hash.new { |h, k| h[k] = 0 },
            modified_tables_by_db: Hash.new { |h, k| h[k] = Set.new }
          })
        end

        def self.enabled?
          ::Feature::FlipperFeature.table_exists? &&
            Feature.enabled?(:detect_cross_database_modification, default_enabled: :yaml)
        end

        # rubocop:disable Metrics/AbcSize
        def self.analyze(parsed)
          return if self.allow_cross_database_modification?
          return if in_factory_bot_create?

          database = ::Gitlab::Database.db_config_name(parsed.connection)
          sql = parsed.sql

          # We ignore BEGIN in tests as this is the outer transaction for
          # DatabaseCleaner
          if sql.start_with?('SAVEPOINT') || (!Rails.env.test? && sql.start_with?('BEGIN'))
            context[:transaction_depth_by_db][database] += 1

            return
          elsif sql.start_with?('RELEASE SAVEPOINT', 'ROLLBACK TO SAVEPOINT') || (!Rails.env.test? && sql.start_with?('ROLLBACK', 'COMMIT'))
            context[:transaction_depth_by_db][database] -= 1
            if context[:transaction_depth_by_db][database] <= 0
              context[:modified_tables_by_db][database].clear
            end

            return
          end

          return if context[:transaction_depth_by_db].values.all?(&:zero?)

          # PgQuery might fail in some cases due to limited nesting:
          # https://github.com/pganalyze/pg_query/issues/209
          tables = sql.downcase.include?(' for update') ? parsed.pg.tables : parsed.pg.dml_tables

          # We have some code where plans and gitlab_subscriptions are lazily
          # created and this causes lots of spec failures
          # https://gitlab.com/gitlab-org/gitlab/-/issues/343394
          tables -= %w[plans gitlab_subscriptions]

          return if tables.empty?

          # All migrations will write to schema_migrations in the same transaction.
          # It's safe to ignore this since schema_migrations exists in all
          # databases
          return if tables == ['schema_migrations']

          context[:modified_tables_by_db][database].merge(tables)
          all_tables = context[:modified_tables_by_db].values.map(&:to_a).flatten
          schemas = ::Gitlab::Database::GitlabSchema.table_schemas(all_tables)

          if schemas.many?
            message = "Cross-database data modification of '#{schemas.to_a.join(", ")}' were detected within " \
              "a transaction modifying the '#{all_tables.to_a.join(", ")}' tables." \
              "Please refer to https://docs.gitlab.com/ee/development/database/multiple_databases.html#removing-cross-database-transactions for details on how to resolve this exception."

            if schemas.any? { |s| s.to_s.start_with?("undefined") }
              message += " The gitlab_schema was undefined for one or more of the tables in this transaction. Any new tables must be added to lib/gitlab/database/gitlab_schemas.yml ."
            end

            raise CrossDatabaseModificationAcrossUnsupportedTablesError, message
          end
        rescue CrossDatabaseModificationAcrossUnsupportedTablesError => e
          ::Gitlab::ErrorTracking.track_exception(e, { gitlab_schemas: schemas, tables: all_tables, query: parsed.sql })
          raise if raise_exception?
        rescue StandardError => e
          # Extra safety net to ensure we never raise in production
          # if something goes wrong in this logic
          Gitlab::ErrorTracking.track_and_raise_for_dev_exception(e)
        end
        # rubocop:enable Metrics/AbcSize

        # We ignore execution in the #create method from FactoryBot
        # because it is not representative of real code we run in
        # production. There are far too many false positives caused
        # by instantiating objects in different `gitlab_schema` in a
        # FactoryBot `create`.
        def self.in_factory_bot_create?
          Rails.env.test? && caller_locations.any? { |l| l.path.end_with?('lib/factory_bot/evaluation.rb') && l.label == 'create' }
        end

        # When in test we raise exception
        def self.raise_exception?
          Rails.env.test?
        end
      end
    end
  end
end
