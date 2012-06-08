require 'json'

# Static counter to count unique values
module PulseMeter
  module Sensor
    class UniqCounter < Counter

      # Processes event
      # @param name [String] value to be counted
      def event(name)
        redis.sadd(value_key, name)
      end

      # Returs number of unique values ever sent to counter
      # @return [Fixnum]
      def value
        redis.scard(value_key)
      end

    end
  end
end
