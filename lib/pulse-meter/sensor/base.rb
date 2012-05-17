module PulseMeter
  module Sensor
    class Base
      include PulseMeter::Mixins::Dumper

      attr_reader :name, :redis

      def initialize(name, options={})
        @name = name.to_s
        if options[:annotation]
          annotate(options[:annotation])
        end
        raise PulseMeter::RedisNotInitialized unless redis
        raise BadSensorName, @name unless @name =~ /\A\w+\z/
        dump!
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
        cleanup_dump
      end

      def event(value)
        # do nothing here
      end

      protected

      def desc_key
        "pulse_meter:desc:#{name}"
      end

      def multi
        redis.multi
        yield
        redis.exec
      end

    end
  end
end
