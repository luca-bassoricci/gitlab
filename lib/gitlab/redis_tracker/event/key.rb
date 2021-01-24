# frozen_string_literal: true

module Gitlab
  module RedisTracker
    module Event
      class Key
        REDIS_SLOT = '{gltracking}'.freeze

        class << self
          def build(key_type, options)
            key = self.new

            redis_key = case key_type
                        when :redis_increment_key
                          key.redis_increment_key(options)
                        when :redis_count_key
                          key.redis_count_key(options)
                        when :redis_increment_distinct_key
                          key.redis_increment_distinct_key(options)
                        when :redis_count_distinct_keys
                          key.redis_count_distinct_keys(options)
                        end

            redis_key
          end
        end

        # "{gltracking}:issues_view_count"
        def redis_increment_key(event:)
          "#{REDIS_SLOT}:#{event}"
        end

        # "{gltracking}:issues_view_count"
        def redis_count_key(event:)
          redis_increment_key(event: event)
        end

        # "{gltracking}:issues_view_count:2021-52:gold"
        # "{gltracking}:issues_view_count:2021-52:gold:another_context"
        def redis_increment_distinct_key(event:, date:, context: nil)
          hll_redis_key(event, date, context)
        end

        # "{gltracking}:issues_view_count:2021-52:gold, {gltracking}:issues_view_count:2021-53:gold"
        # "{gltracking}:issues_view_count:2021-52:gold:another_context"
        def redis_count_distinct_keys(events:, start_date:, end_date:, context: nil)
          hll_weekly_redis_keys(events: Array(events), start_date: start_date, end_date: end_date, context: context)
        end

        private

        def hll_weekly_redis_keys(events:, start_date:, end_date:, context: nil)
          end_date = end_date.end_of_week
          (start_date.to_date..end_date.to_date).map do |date|
            events.map { |event| hll_redis_key(event, date, context) }
          end.flatten.uniq
        end

        def hll_redis_key(event, date, context = nil)
          "#{REDIS_SLOT}:#{event}:#{year_week(date)}#{context_key(context)}"
        end

        def year_week(date)
          date.strftime('%G-%V')
        end

        def context_key(context)
          return '' unless context.present?

          context.to_h.map { |key, value| ":#{value}" }.join
        end
      end
    end
  end
end
