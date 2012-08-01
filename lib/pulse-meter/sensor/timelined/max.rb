module PulseMeter
  module Sensor
    module Timelined
      # Calculates max value in interval
      class Max < Timeline

        def aggregate_event(key, value)
          redis.zadd(key, value, "#{value}::#{uniqid}")
          redis.zremrangebyrank(key, 0, -2)
        end

        def summarize(key)
          count = redis.zcard(key)
          if count > 0
            max_el = redis.zrange(key, -1, -1)[0]
            redis.zscore(key, max_el)
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
