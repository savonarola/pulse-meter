module PulseMeter
  module Sensor
    module Timelined
      # Calculates max value in interval
      class Max < ZSetBased

        def update(key)
          command_aggregator.zremrangebyrank(key, 0, -2)
        end

        def calculate(key, _)
          max_el = redis.zrange(key, -1, -1)[0]
          redis.zscore(key, max_el)
        end

      end
    end
  end
end
