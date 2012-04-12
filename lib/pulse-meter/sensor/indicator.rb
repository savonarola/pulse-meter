module PulseMeter
  module Sensor
    class Indicator < Base

      def cleanup
        redis.del(value_key)
        super
      end

      def event(value)
        redis.set(value_key, value.to_f)
      end

      def value
        val = redis.get(value_key)
        val.nil? ? 0 : val.to_f
      end

      def value_key
        @value_key ||= "#{name}:value"
      end

    end

  end
end

