# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Back-fills the `issues.namespace_id` by setting it to corresponding project.project_namespace_id
    class BackfillProjectNamespaceOnIssues < BatchedMigrationJob
      def perform
        cleanup_gin_index('issues')

        each_sub_batch(
          operation_name: :update_all,
          batching_scope: -> (relation) {
            relation.joins("INNER JOIN projects ON projects.id = issues.project_id")
              .select("issues.id AS issue_id, projects.project_namespace_id").where(issues: { namespace_id: nil })
          }
        ) do |sub_batch|
          ApplicationRecord.connection.execute <<~SQL
            UPDATE issues
            SET namespace_id = projects.project_namespace_id
            FROM (#{sub_batch.to_sql}) AS projects(issue_id, project_namespace_id)
            WHERE issues.id = issue_id
          SQL
        end
      end

      private

      def cleanup_gin_index(table_name)
        index_names = ApplicationRecord.connection.select_values <<~SQL
          select indexname::text from pg_indexes where tablename = '#{table_name}' and indexdef ilike '%using gin%'
        SQL

        index_names.each do |index_name|
          ApplicationRecord.connection.execute("select gin_clean_pending_list('#{index_name}')")
        end
      end
    end
  end
end
