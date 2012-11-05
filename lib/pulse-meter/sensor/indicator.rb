module PulseMeter
  module Sensor
    # Static indicator. In fact is is just a named variable with float value
    class Indicator < Base

      # Cleans up all sensor metadata in Redis
      def cleanup
        redis.del(value_key)
        super
      end

      # Get indicator value
      # @return [Fixnum] indicator value or zero unless it was initialized
      def value
        val = redis.get(value_key)
        val.nil? ? 0 : val.to_f
      end

      # Gets redis key by which counter value is stored
      # @return [String]
      def value_key
        @value_key ||= "pulse_meter:value:#{name}"
      end

      private

      # Sets indicator value
      # @param value [Float] new indicator value
      def process_event(value)
        command_aggregator.set(value_key, value.to_f)
      end

    end
  end
end
