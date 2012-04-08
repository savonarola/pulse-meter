require 'sequrerandom'
module PulseMeter
  module Sensor
    module Timeline 
      class MinMax
        protected

        def uniqid
          SecureRandom.hex(32)
        end

        def aggregate_event(value)
          multi do
            redis.zadd(current_key, value, uniqid)
            redis.zremrangebyrank(current_key, 1, -2)
          end
        end

        def self.summarize(redis, summarize_from, summarize_to, options)
          count = redis.zcard(summarize_from)
          min = 0
          max = 0
          if count > 0
            min_el = redis.zrange(summarize_from, 0, 0)
            max_el = redis.zrange(summarize_from, -1, -1)
            min = redis.zscore(min_el)
            max = redis.zscore(max_el)
          end
          redis.hset(summarize_to, :min, min)
          redis.hset(summarize_to, :max, max)
        end
      end
    end
  end
end


