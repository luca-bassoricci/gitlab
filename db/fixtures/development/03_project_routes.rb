class Gitlab::Seeder::ProjectRoutes
  include ActionView::Helpers::NumberHelper

  BATCH_SIZE = 100_000

  def seed!
    create_project_routes!
  end

  def create_project_routes!
    Gitlab::Seeder.with_mass_insert(Project.count, "Project routes") do
      Project.each_batch(of: BATCH_SIZE / 2) do |batch, index|
        range = batch.pluck(Arel.sql('MIN(id)'), Arel.sql('MAX(id)')).first
        puts "Creating #{index * BATCH_SIZE / 2} project routes."

        ActiveRecord::Base.connection.execute <<~SQL
          INSERT INTO routes (source_id, source_type, name, path)
          SELECT
            p.id,
            'Project',
            routes.name || ' / ' || p.name,
            routes.path || '/' || p.path
          FROM projects p
          INNER JOIN routes ON routes.source_id = p.namespace_id and source_type = 'Namespace'
          WHERE p.id BETWEEN #{range.first} AND #{range.last}
          --WHERE p.path like 'mass_%'
          ON CONFLICT (source_type, source_id) DO NOTHING;
        SQL
      end
    end
  end
end

Gitlab::Seeder.quiet do
  projects = Gitlab::Seeder::ProjectRoutes.new
  projects.seed!
end
