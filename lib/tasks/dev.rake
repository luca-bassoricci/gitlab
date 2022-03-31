# frozen_string_literal: true

task dev: ["dev:setup"]

namespace :dev do
  desc "GitLab | Dev | Setup developer environment (db, fixtures)"
  task setup: :environment do
    ENV['force'] = 'yes'
    Rake::Task["gitlab:setup"].invoke

    Gitlab::Database::EachDatabase.each_database_connection do |connection|
      # Make sure DB statistics are up to date.
      # gitlab:setup task can insert quite a bit of data, especially with MASS_INSERT=1
      # so ANALYZE can take more than default 15s statement timeout. This being a dev task,
      # we disable the statement timeout for ANALYZE to run and enable it back afterwards.
      connection.execute('SET statement_timeout TO 0')
      connection.execute('ANALYZE')
      connection.execute('RESET statement_timeout')
    end

    Rake::Task["gitlab:shell:setup"].invoke
  end

  desc "GitLab | Dev | Eager load application"
  task load: :environment do
    Rails.configuration.eager_load = true
    Rails.application.eager_load!
  end

  databases = ActiveRecord::Tasks::DatabaseTasks.setup_initial_database_yaml

  namespace :copy_db do
    ALLOWED_DATABASES = %w[ci].freeze

    ActiveRecord::Tasks::DatabaseTasks.for_each(databases) do |name|
      next unless ALLOWED_DATABASES.include?(name)

      desc "Copies the #{name} database from the main database"
      task name => :environment do
        db_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: name)

        ApplicationRecord.connection.create_database(db_config.database, template: ApplicationRecord.connection_db_config.database)
      rescue ActiveRecord::DatabaseAlreadyExists
        warn "Database '#{db_config.database}' already exists"
      end
    end
  end
end
