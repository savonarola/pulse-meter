module PulseMeter
  module Sensor
    module Timelined
      # Calculates min value in interval
      class Min < ZSetBased

        def update(key)
          command_aggregator.zremrangebyrank(key, 1, -1)
        end

        def calculate(key, _)
          min_el = redis.zrange(key, 0, 0)[0]
          redis.zscore(key, min_el)
        end

      end
    end
  end
end
