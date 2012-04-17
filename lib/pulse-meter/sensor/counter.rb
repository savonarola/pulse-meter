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
        val = redis.get(value_key)
        val.nil? ? 0 : val.to_i
      end

      def value_key
        @value_key ||= "#{name}:value"
      end
    end
  end
end
