module PulseMeter
  module Sensor
    module Timelined
      # Counts unique events per interval
      class UniqCounter < Timeline
        def aggregate_event(key, value)
          redis.sadd(key, value)
        end

        def summarize(key)
          redis.scard(key)
        end
      end
    end
  end
end
