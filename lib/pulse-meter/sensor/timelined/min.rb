module PulseMeter
  module Sensor
    module Timelined
      # Calculates min value in interval
      class Min < Timeline

        def aggregate_event(key, value)
          redis.zadd(key, value, "#{value}::#{uniqid}")
          redis.zremrangebyrank(key, 1, -1)
        end

        def summarize(key)
          count = redis.zcard(key)
          if count > 0
            min_el = redis.zrange(key, 0, 0)[0]
            redis.zscore(key, min_el)
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
