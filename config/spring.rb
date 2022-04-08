# frozen_string_literal: true

require "spring/application"

%w(
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
).each { |path| Spring.watch(path) }

Spring.after_fork do
  if ENV['DEBUGGER_STORED_RUBYLIB']
    ENV['DEBUGGER_STORED_RUBYLIB'].split(File::PATH_SEPARATOR).each do |path|
      next unless path =~ /ruby-debug-ide/

      load path + '/ruby-debug-ide/multiprocess/starter.rb'
    end
  end
end

module DisconnectAllDatabases
  def disconnect_database
    ::Gitlab::Database.database_base_models.each do |_name, base_model|
      base_model.remove_connection
    end
  end

  def connect_database
    ::Gitlab::Database.database_base_models.each do |_name, base_model|
      base_model.establish_connection # rubocop:disable Database/EstablishConnection
    end
  end
end

Spring::Application.prepend(DisconnectAllDatabases)
