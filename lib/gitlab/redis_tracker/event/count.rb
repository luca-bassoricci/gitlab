# frozen_string_literal: true

module Gitlab
  module RedisTracker
    module Event
      class Count
        def initialize(event:)
          @redis_key = Gitlab::RedisTracker::Event::Key.build(:redis_count_key, event: event)
        end

        def fetch
          Gitlab::Redis::SharedState.with { |redis| redis.get(@redis_key).to_i }
        end
      end
    end
  end
end
