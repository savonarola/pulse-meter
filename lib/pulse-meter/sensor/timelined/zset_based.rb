module PulseMeter
  module Sensor
    module Timelined
      class ZSetBased < Timeline

        def update(_)
        end

        def calculate(key)
          0
        end

        def aggregate_event(key, value)
          command_aggregator.zadd(key, value, "#{value}::#{uniqid}")
          update(key)
        end

        def summarize(key)
          count = redis.zcard(key)
          if count > 0
            calculate(key, count)
          else
            nil
          end
        end

        private

        def deflate(value)
          value.to_f
        end

      end
    end
  end
end

