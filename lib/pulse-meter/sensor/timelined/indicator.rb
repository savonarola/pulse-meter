module PulseMeter
  module Sensor
    module Timelined
      # Saves last registered flag float value for each interval
      class Indicator < Timeline
        def aggregate_event(key, value)
          redis.set(key, value.to_f)
        end

        def summarize(key)
          redis.get(key)
        end

        private

        def deflate(value)
          value.to_f
        end

      end
    end
  end
end
