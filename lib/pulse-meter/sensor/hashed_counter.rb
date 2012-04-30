require 'json'

module PulseMeter
  module Sensor
    class HashedCounter < Counter

      def incr(key)
        event({key => 1})
      end

      def event(data)
        data.each_pair {|k, v| redis.hincrby(value_key, k, v.to_i)}
      end

      def value
        redis.
          hgetall(value_key).
          inject(Hash.new(0)) {|h, (k, v)| h[k] = v.to_i; h}
      end

    end
  end
end
