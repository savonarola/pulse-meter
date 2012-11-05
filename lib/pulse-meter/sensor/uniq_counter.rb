require 'json'

# Static counter to count unique values
module PulseMeter
  module Sensor
    class UniqCounter < Counter

      # Returs number of unique values ever sent to counter
      # @return [Fixnum]
      def value
        redis.scard(value_key)
      end

      private

      # Processes event
      # @param name [String] value to be counted
      def process_event(name)
        command_aggregator.sadd(value_key, name)
      end

    end
  end
end
