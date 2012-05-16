module PulseMeter
  module Sensor
    class Counter < Base

      def cleanup
        redis.del(value_key)
        super
      end

      def incr
        event(1)
      end

      def event(value)
        redis.incrby(value_key, value.to_i)
      end

      def value
        redis.get(value_key).to_i
      end

      def value_key
        @value_key ||= "pulse_meter:value:#{name}"
      end
    end
  end
end
