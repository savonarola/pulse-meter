require 'json'

module PulseMeter
  module Sensor
    module Timelined
      # Saves last registered values for multiple flags per interval.
      # Good replacement for multiple indicators to be visualized together
      class HashedIndicator < Timeline
        def aggregate_event(key, data)
          data.each_pair do |k, v|
            redis.hset(key, k, v) if v.respond_to?(:to_f)
          end
        end

        def summarize(key)
          redis.
            hgetall(key).
            inject({}) {|h, (k, v)| h[k] = v.to_f; h}.
            to_json
        end

        private

        def deflate(value)
          JSON.parse(value)
        end
      end
    end
  end
end
