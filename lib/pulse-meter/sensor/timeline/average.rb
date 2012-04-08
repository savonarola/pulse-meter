module PulseMeter
  module Sensor
    module Timeline 
      class Average
        protected

        def aggregate_event(value)
          multi do
            redis.hincrby(current_key, :count, 1)
            redis.hincrbyfloat(current_key, :value, value)
          end
        end

        def self.summarize(redis, summarize_from, summarize_to, options)
          count = redis.hget(summarize_from, :count)
          value = redis.hget(summarize_from, :value)
          res = if count && !count.empty?
            value.to_f / count.to_f
          else
            0
          end
          redis.set(summarize_to, res)
        end
      end
    end
  end
end

