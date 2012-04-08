module PulseMeter
  module Sensor
    module Timeline 
      class Counter
        def incr
          event(1)  
        end

        protected

        def aggregate_event(value)
          redis.incrby(current_key, value.to_i)
        end

        def self.summarize(redis, summarize_from, summarize_to, options)
          redis.renamenx(summarize_from, summarize_to)
        end
      end
    end
  end
end

