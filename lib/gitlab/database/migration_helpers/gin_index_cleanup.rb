# frozen_string_literal: true

module Gitlab
  module Database
    module MigrationHelpers
      module GinIndexCleanup
        def cleanup_gin_index(connection, table_name)
          sql = <<-SQL
            SELECT indexname::text FROM pg_indexes WHERE tablename = '#{table_name}' AND indexdef ILIKE '%using gin%'
          SQL

          index_names = connection.select_values(sql)

          index_names.each do |index_name|
            connection.execute("SELECT gin_clean_pending_list('#{index_name}')")
          end
        end
      end
    end
  end
end
