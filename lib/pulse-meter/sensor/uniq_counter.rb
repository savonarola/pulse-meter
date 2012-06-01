require 'json'

# Static counter to count unique values
module PulseMeter
  module Sensor
    class UniqCounter < Counter

      # Processes event
      # @param name [String] value to be counted
      def event(name)
        redis.hset(value_key, name, 1)        
      end

      # Returs number of unique values ever sent to counter
      # @return [Fixnum]
      def value
        redis.hlen(value_key)
      end

    end
  end
end
