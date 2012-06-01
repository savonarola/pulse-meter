module PulseMeter
  module Sensor
    module Timelined
      # Counts unique events per interval
      class UniqCounter < Timeline
        def aggregate_event(key, value)
          redis.hset(key, value, 1)
        end

        def summarize(key)
          redis.hlen(key) || 0
        end
      end
    end
  end
end
