class Gitlab::Seeder::Projects
  include ActionView::Helpers::NumberHelper

  PROJECT_URLS = %w[
    https://gitlab.com/gitlab-org/gitlab-test.git
    https://gitlab.com/gitlab-org/gitlab-shell.git
    https://gitlab.com/gnuwget/wget2.git
    https://gitlab.com/Commit451/LabCoat.git
    https://github.com/jashkenas/underscore.git
    https://github.com/flightjs/flight.git
    https://github.com/twitter/typeahead.js.git
    https://github.com/h5bp/html5-boilerplate.git
    https://github.com/google/material-design-lite.git
    https://github.com/jlevy/the-art-of-command-line.git
    https://github.com/FreeCodeCamp/freecodecamp.git
    https://github.com/google/deepdream.git
    https://github.com/jtleek/datasharing.git
    https://github.com/WebAssembly/design.git
    https://github.com/airbnb/javascript.git
    https://github.com/tessalt/echo-chamber-js.git
    https://github.com/atom/atom.git
    https://github.com/mattermost/mattermost-server.git
    https://github.com/purifycss/purifycss.git
    https://github.com/facebook/nuclide.git
    https://github.com/wbkd/awesome-d3.git
    https://github.com/kilimchoi/engineering-blogs.git
    https://github.com/gilbarbara/logos.git
    https://github.com/reduxjs/redux.git
    https://github.com/awslabs/s2n.git
    https://github.com/arkency/reactjs_koans.git
    https://github.com/twbs/bootstrap.git
    https://github.com/chjj/ttystudio.git
    https://github.com/MostlyAdequate/mostly-adequate-guide.git
    https://github.com/octocat/Spoon-Knife.git
    https://github.com/opencontainers/runc.git
    https://github.com/googlesamples/android-topeka.git
  ]
  LARGE_PROJECT_URLS = %w[
    https://github.com/torvalds/linux.git
    https://gitlab.gnome.org/GNOME/gimp.git
    https://gitlab.gnome.org/GNOME/gnome-mud.git
    https://gitlab.com/fdroid/fdroidclient.git
    https://gitlab.com/inkscape/inkscape.git
    https://github.com/gnachman/iTerm2.git
  ]
  # Consider altering MASS_USERS_COUNT for less
  # users with projects.
  MASS_PROJECTS_COUNT_PER_USER = {
    private: 3, # 3m projects +
    internal: 1, # 1m projects +
    public: 1 # 1m projects = 5m total
  }

  BATCH_SIZE = 100_000

  def seed!
    create_mass_projects!
  end

  def create_mass_projects!
    projects_per_user_count   = MASS_PROJECTS_COUNT_PER_USER.values.sum
    visibility_per_user       = ['private'] * MASS_PROJECTS_COUNT_PER_USER.fetch(:private) +
      ['internal'] * MASS_PROJECTS_COUNT_PER_USER.fetch(:internal) +
      ['public'] * MASS_PROJECTS_COUNT_PER_USER.fetch(:public)
    visibility_level_per_user = visibility_per_user.map { |visibility| Gitlab::VisibilityLevel.level_value(visibility) }

    visibility_per_user       = visibility_per_user.join(',')
    visibility_level_per_user = visibility_level_per_user.join(',')

    Gitlab::Seeder.with_mass_insert(User.count * projects_per_user_count, "Projects and relations") do
      puts "#{Time.now} creating personal projects"
      ActiveRecord::Base.connection.execute <<~SQL
        INSERT INTO projects (name, path, creator_id, namespace_id, visibility_level, created_at, updated_at)
        SELECT
          'Seed project ' || seq || ' ' || ('{#{visibility_per_user}}'::text[])[seq] AS project_name,
          '#{Gitlab::Seeder::MASS_INSERT_PROJECT_START}' || ('{#{visibility_per_user}}'::text[])[seq] || '_' || seq AS project_path,
          u.id AS user_id,
          n.id AS namespace_id,
          ('{#{visibility_level_per_user}}'::int[])[seq] AS visibility_level,
          NOW() AS created_at,
          NOW() AS updated_at
        FROM users u
          CROSS JOIN generate_series(1, #{projects_per_user_count}) AS seq
          JOIN namespaces n ON n.owner_id=u.id
        WHERE u.username like 'mass_%'
      SQL
    end

    Gitlab::Seeder.with_mass_insert(Namespace.where("path LIKE 'mass_%'").count * projects_per_user_count, "Group projects") do
      Namespace.each_batch(of: BATCH_SIZE) do |batch, index|
        range = batch.pluck(Arel.sql('MIN(id)'), Arel.sql('MAX(id)')).first
        puts "Creating #{index * BATCH_SIZE * projects_per_user_count} projects."

        ActiveRecord::Base.connection.execute <<~SQL
          INSERT INTO projects (name, path, creator_id, namespace_id, visibility_level, created_at, updated_at)
          SELECT
            'Seed project ' || seq || ' ' || ('{#{visibility_per_user}}'::text[])[seq] AS project_name,
            '#{Gitlab::Seeder::MASS_INSERT_PROJECT_START}' || ('{#{visibility_per_user}}'::text[])[seq] || '_' || seq AS project_path,
            #{User.first.id} AS user_id,
            namespaces.id AS namespace_id,
            ('{#{visibility_level_per_user}}'::int[])[seq] AS visibility_level,
            NOW() AS created_at,
            NOW() AS updated_at
          FROM namespaces
            CROSS JOIN generate_series(1, #{projects_per_user_count}) AS seq
          WHERE type='Group' AND path LIKE 'mass_%' AND namespaces.id BETWEEN #{range.first} AND #{range.last}
        SQL
      end
    end
  end
end

Gitlab::Seeder.quiet do
  projects = Gitlab::Seeder::Projects.new
  projects.seed!
end
