# frozen_string_literal: true

class Gitlab::Seeder::Users
  include ActionView::Helpers::NumberHelper

  RANDOM_USERS_COUNT = 20
  MASS_USERS_COUNT = 1000

  attr_reader :opts

  def initialize(opts = {})
    @opts = opts
  end

  def seed!
    create_mass_users!
    create_mass_namespaces!
  end

  private

  def create_mass_users!
    encrypted_password = Devise::Encryptor.digest(User, random_password)

    Gitlab::Seeder.with_mass_insert(MASS_USERS_COUNT, User) do
      ActiveRecord::Base.connection.execute <<~SQL
        INSERT INTO users (username, name, email, confirmed_at, projects_limit, encrypted_password)
        SELECT
          '#{Gitlab::Seeder::MASS_INSERT_USER_START}' || seq,
          'Seed user ' || seq,
          'seed_user' || seq || '@example.com',
          to_timestamp(seq),
          #{MASS_USERS_COUNT},
          '#{encrypted_password}'
        FROM generate_series(1, #{MASS_USERS_COUNT}) AS seq
      SQL
    end

    relation = User.where(admin: false)
    Gitlab::Seeder.with_mass_insert(relation.count, Namespace) do
      ActiveRecord::Base.connection.execute <<~SQL
        INSERT INTO namespaces (name, path, owner_id)
        SELECT
          username,
          username,
          id
        FROM users WHERE NOT admin
      SQL
    end

    puts '==========================================================='
    puts "INFO: Password for newly created users is: #{random_password}"
    puts '==========================================================='
  end

  def create_mass_namespaces!
    Gitlab::Seeder.with_mass_insert(MASS_USERS_COUNT, Namespace) do
      ActiveRecord::Base.connection.execute <<~SQL
        INSERT INTO namespaces (name, path, type)
        SELECT
          'mass insert group level 0 - ' || seq,
          'mass_insert_group_0_' || seq,
          'Group'
        FROM generate_series(1, #{MASS_USERS_COUNT}) AS seq
      SQL

      (1..9).each do |idx|
        puts "#{Time.now} creating subgroups level #{idx}"
        ActiveRecord::Base.connection.execute <<~SQL
          INSERT INTO namespaces (name, path, type, parent_id)
          SELECT
            'mass insert group level #{idx} - ' || seq,
            'mass_insert_group_#{idx}_' || seq,
            'Group',
            namespaces.id
          FROM namespaces
          CROSS JOIN generate_series(1, 2) AS seq
          WHERE namespaces.type='Group' AND namespaces.path like 'mass_insert_group_#{idx-1}_%'
        SQL
      end

      puts "#{Time.now} creating routes"
      ActiveRecord::Base.connection.execute <<~SQL
        WITH RECURSIVE cte(source_id, namespace_id, parent_id, path, height) AS (
          (
            SELECT ARRAY[batch.id], batch.id, batch.parent_id, batch.path, 1
            FROM
              "namespaces" as batch
            WHERE
              "batch"."type" = 'Group' AND "batch"."parent_id" is null
          )
        UNION
          (
            SELECT array_append(cte.source_id, n.id), n.id, n.parent_id, cte.path || '/' || n.path, cte.height+1
            FROM
              "namespaces" as n,
              "cte"
            WHERE
              "n"."type" = 'Group'
              AND "n"."parent_id" = "cte"."namespace_id"
          )
        )
        INSERT INTO routes (source_id, source_type, path, name)
          SELECT cte.namespace_id, 'Namespace', cte.path, cte.path FROM cte
          ON CONFLICT (source_type, source_id) DO NOTHING;
      SQL

      puts "#{Time.now} filling traversal ids"
      ActiveRecord::Base.connection.execute <<~SQL
        WITH RECURSIVE cte(source_id, namespace_id, parent_id) AS (
                  (
                    SELECT ARRAY[batch.id], batch.id, batch.parent_id
                    FROM
                      "namespaces" as batch
                    WHERE
                      "batch"."type" = 'Group' AND "batch"."parent_id" is null
                  )
                UNION
                  (
                    SELECT array_append(cte.source_id, n.id), n.id, n.parent_id
                    FROM
                      "namespaces" as n,
                      "cte"
                    WHERE
                      "n"."type" = 'Group'
                      AND "n"."parent_id" = "cte"."namespace_id"
                  )
                )
        update namespaces
        set traversal_ids = computed.source_id from (SELECT namespace_id, source_id FROM cte) as computed
        where computed.namespace_id = namespaces.id AND namespaces.path like 'mass_insert_%'
      SQL

      puts "#{Time.now} creating namespace settings"
      ActiveRecord::Base.connection.execute <<~SQL
        INSERT INTO namespace_settings(namespace_id, created_at, updated_at)
        SELECT id, now(), now() FROM namespaces
        ON CONFLICT DO NOTHING;
      SQL
    end
  end

  def random_password
    @random_password ||= SecureRandom.hex.slice(0,16)
  end
end

Gitlab::Seeder.quiet do
  users = Gitlab::Seeder::Users.new
  users.seed!
end
