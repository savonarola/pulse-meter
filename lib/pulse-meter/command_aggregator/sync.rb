require 'singleton'

module PulseMeter
  module CommandAggregator
    class Sync
      include Singleton

      def redis
        PulseMeter.redis
      end

      def method_missing(*args, &block)
        redis.send(*args, &block)
      end
    end
  end
end

