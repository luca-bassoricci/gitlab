# frozen_string_literal: true

module Gitlab
  module RedisTracker
    module Event
      class CountDistinctIntersection
        def initialize(events:, start_date:, end_date:, context: nil)
          @redis_keys = Gitlab::RedisTracker::Event::Key.build(:redis_count_distinct_interesction_key, events: events, start_date: start_date, end_date: end_date, context: context)
        end

        def fetch
          # TODO
        end
      end
    end
  end
end
