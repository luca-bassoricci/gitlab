# frozen_string_literal: true

namespace :gitlab do
  namespace :db do
    TRIGGER_FUNCTION_NAME = 'gitlab_schema_prevent_write'

    desc "GitLab | DB | Install prevent write triggers on all databases"
    task lock_writes: [:environment, 'gitlab:db:validate_config'] do
      Gitlab::Database::EachDatabase.each_database_connection do |connection, database_name|
        create_write_trigger_function(connection)

        schemas_for_connection = Gitlab::Database.gitlab_schemas_for_connection(connection)
        Gitlab::Database::GitlabSchema.tables_to_schema.each do |table_name, schema_name|
          connection.transaction do
            if schemas_for_connection.include?(schema_name.to_sym)
              drop_write_trigger(database_name, connection, table_name)
            else
              create_write_trigger(database_name, connection, table_name)
            end
          end
        end
      end
    end

    desc "GitLab | DB | Remove all triggers that prevents writes from all databases"
    task unlock_writes: :environment do
      Gitlab::Database::EachDatabase.each_database_connection do |connection, database_name|
        Gitlab::Database::GitlabSchema.tables_to_schema.each do |table_name, schema_name|
          drop_write_trigger(database_name, connection, table_name)
        end
        drop_write_trigger_function(connection)
      end
    end

    def create_write_trigger_function(connection)
      sql = <<-SQL
        CREATE OR REPLACE FUNCTION #{TRIGGER_FUNCTION_NAME}()
          RETURNS TRIGGER AS
          $$
          BEGIN
            RAISE EXCEPTION 'Table: "%" is write protected within this Gitlab database.', TG_TABLE_NAME
              USING ERRCODE = 'modifying_sql_data_not_permitted',
              HINT = 'Make sure you are using the right database connection';
          END
          $$ LANGUAGE PLPGSQL
      SQL

      connection.execute(sql)
    end

    def drop_write_trigger_function(connection)
      sql = <<-SQL
        DROP FUNCTION IF EXISTS #{TRIGGER_FUNCTION_NAME}()
      SQL

      connection.execute(sql)
    end

    def create_write_trigger(database_name, connection, table_name)
      puts "#{database_name}: '#{table_name}'... Lock Writes".color(:red)
      sql = <<-SQL
          DROP TRIGGER IF EXISTS #{write_trigger_name(table_name)} ON #{table_name};
          CREATE TRIGGER #{write_trigger_name(table_name)}
            BEFORE INSERT OR UPDATE OR DELETE OR TRUNCATE
            ON #{table_name}
            FOR EACH STATEMENT EXECUTE FUNCTION #{TRIGGER_FUNCTION_NAME}();
      SQL

      connection.execute(sql)
    end

    def drop_write_trigger(database_name, connection, table_name)
      puts "#{database_name}: '#{table_name}'... Allow Writes".color(:green)
      sql = <<-SQL
        DROP TRIGGER IF EXISTS #{write_trigger_name(table_name)} ON #{table_name}
      SQL

      connection.execute(sql)
    end

    def write_trigger_name(table_name)
      "gitlab_schema_write_trigger_for_#{table_name}"
    end
  end
end
