module PulseMeter
  module Sensor
    # Static hashed indicator. In fact is is just a named hash with float value
    class HashedIndicator < Indicator

      # Get indicator values
      # @return [Fixnum] indicator value or zero unless it was initialized
      def value
        redis.
          hgetall(value_key).
          inject(Hash.new(0)) {|h, (k, v)| h[k] = v.to_f; h}
      end

      private

      # Sets indicator values
      # @param value [Hash] new indicator values
      def process_event(events)
        events.each_pair {|name, value| redis.hset(value_key, name, value.to_f)}
      end

    end
  end
end
