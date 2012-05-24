# Static counter
module PulseMeter
  module Sensor
    class Counter < Base

      # Cleans up all sensor metadata in Redis
      def cleanup
        redis.del(value_key)
        super
      end

      # Increments counter value by 1
      def incr
        event(1)
      end

      # Processes event by incremnting counter by given value
      # @param value [Fixnum] increment
      def event(value)
        redis.incrby(value_key, value.to_i)
      end

      # Gets counter value
      # @return [Fixnum]
      def value
        redis.get(value_key).to_i
      end
      
      # Gets redis key by which counter value is stored
      # @return [String]
      def value_key
        @value_key ||= "pulse_meter:value:#{name}"
      end
    end
  end
end
