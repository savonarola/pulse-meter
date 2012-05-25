module PulseMeter
  module Sensor
    module Timelined
      # Calculates n'th percentile in interval
      class Percentile < Timeline
        attr_reader :p_value

        def initialize(name, options)
          @p_value = assert_ranged_float!(options, :p, 0, 1)
          super(name, options)
        end

        def aggregate_event(key, value)
          redis.zadd(key, value, "#{value}::#{uniqid}")
        end

        def summarize(key)
          count = redis.zcard(key)
          if count > 0
            position = @p_value > 0 ? (@p_value * count).round - 1 : 0
            el = redis.zrange(key, position, position)[0]
            redis.zscore(key, el).to_f
          else
            nil
          end
        end

      end
    end
  end
end
