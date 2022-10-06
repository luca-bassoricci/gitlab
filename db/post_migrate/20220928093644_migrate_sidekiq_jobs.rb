# frozen_string_literal: true

class MigrateSidekiqJobs < Gitlab::Database::Migration[2.0]
  # Migrate jobs that don't belong to current routing rules
  # https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/1930

  def up
    queues = scan_queues
    migrate_jobs(queues)
  end

  def down
    # no-op
  end

  private

  def scan_queues
    queues = []
    routing_rules_queues = Settings.sidekiq.routing_rules.map { |query, rule| rule }
    Sidekiq.redis do |conn| # rubocop:disable Cop/SidekiqRedisCall
      conn.scan_each(match: "queue:*", type: 'list') do |key|
        queue = key.split(':').last
        queues << queue unless routing_rules_queues.include? queue
      end
    end
    queues.uniq
  end

  def migrate_jobs(queues_from)
    queues_from.each do |queue_from|
      while sidekiq_queue_length(queue_from) > 0
        Sidekiq.redis do |conn| # rubocop:disable Cop/SidekiqRedisCall
          payload = conn.rpop "queue:#{queue_from}"
          parsed = Gitlab::Json.parse payload
          next if parsed['class'].nil?

          worker_class = Object.const_get(parsed['class'], false)
          conn.lpush("queue:#{worker_class.queue}", payload) unless worker_class.queue == queue_from
        rescue JSON::ParserError
          next
        end
      end
    end
  end
end
