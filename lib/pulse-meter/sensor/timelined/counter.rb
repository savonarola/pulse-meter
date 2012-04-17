module PulseMeter
  module Sensor
    module Timelined
      class Counter < Timeline
        def aggregate_event(key, value)
          redis.incrby(key, value.to_i)
        end

        def summarize(key)
          redis.get(key).to_i
        end
      end
    end
  end
end
