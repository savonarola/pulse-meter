require 'json'

module PulseMeter
  module Sensor
    module Timelined
      # Counts multiple types of events per interval.
      # Good replacement for multiple counters to be visualized together
      class HashedCounter < Timeline
        def aggregate_event(key, data)
          data.each_pair {|k, v| redis.hincrby(key, k, v)}
        end

        def summarize(key)
          redis.
            hgetall(key).
            inject({}) {|h, (k, v)| h[k] = v.to_i; h}.
            to_json
        end
      end
    end
  end
end
