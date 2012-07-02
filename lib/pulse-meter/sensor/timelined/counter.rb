module PulseMeter
  module Sensor
    module Timelined
      # Counts events per interval
      class Counter < Timeline
        def aggregate_event(key, value)
          redis.incrby(key, value.to_i)
        end

        def summarize(key)
          redis.get(key)
        end

        private

        def deflate(value)
          value.to_i
        end

      end
    end
  end
end
