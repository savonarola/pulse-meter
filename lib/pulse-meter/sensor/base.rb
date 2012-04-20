module PulseMeter
  module Sensor
    class Base
      include PulseMeter::Mixins::Dumper

      attr_accessor :redis
      attr_reader :name

      def initialize(name, options={})
        @name = name.to_s
        @options = options
        raise BadSensorName, @name unless @name =~ /\A\w+\z/
        raise RedisNotInitialized unless PulseMeter.redis
      end

      def redis
        PulseMeter.redis
      end
      
      def annotate(description)
        redis.set(desc_key, description)
      end

      def annotation
        redis.get(desc_key)
      end

      def cleanup
        redis.del(desc_key)
      end

      def event(value)
        # do nothing here
      end

      protected

      def desc_key
        "#{name}:desc"
      end

      def multi
        redis.multi 
        yield
        redis.exec
      end

    end
  end
end
