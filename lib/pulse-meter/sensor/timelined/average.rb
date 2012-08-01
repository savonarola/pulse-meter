module PulseMeter
  module Sensor
    module Timelined
      # Average value over interval
      class Average < Timeline

        def aggregate_event(key, value)
          redis.hincrby(key, :count, 1)
          redis.hincrby(key, :sum, value)
        end

        def summarize(key)
          count = redis.hget(key, :count)
          sum = redis.hget(key, :sum)
          if count && !count.empty?
            sum.to_f / count.to_f
          else
            0
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

