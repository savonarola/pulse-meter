module PulseMeter
  module Sensor
    module Timelined
      # Calculates n'th percentile in interval
      class Percentile < ZSetBased
        attr_reader :p_value

        def initialize(name, options)
          @p_value = assert_ranged_float!(options, :p, 0, 1)
          super(name, options)
        end

        def calculate(key, count)
          position = @p_value > 0 ? (@p_value * count).round - 1 : 0
          el = redis.zrange(key, position, position)[0]
          redis.zscore(key, el)
        end

      end
    end
  end
end
