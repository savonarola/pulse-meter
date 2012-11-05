module PulseMeter
  module Sensor
    # @abstract Subclass and override {#event} to implement sensor 
    class Base
      include PulseMeter::Mixins::Dumper

      # @!attribute [rw] redis
      #   @return [Redis] 
      attr_accessor :redis
      # @!attribute [r] name
      #   @return [String] sensor name
      attr_reader :name

      # Initializes sensor and dumps it to redis
      # @param name [String] sensor name
      # @option options [String] :annotation Sensor annotation
      # @raise [BadSensorName] if sensor name is malformed
      # @raise [RedisNotInitialized] unless Redis is initialized
      def initialize(name, options={})
        @name = name.to_s
        if options[:annotation]
          annotate(options[:annotation])
        end
        raise BadSensorName, @name unless @name =~ /\A\w+\z/
        raise RedisNotInitialized unless PulseMeter.redis
        dump!
      end

      # Returns Redis instance
      def redis
        PulseMeter.redis
      end

      def command_aggregator
        PulseMeter.command_aggregator
      end

      # Saves annotation to Redis
      # @param description [String] Sensor annotation
      def annotate(description)
        redis.set(desc_key, description)
      end

      # Retrieves annotation from Redis
      # @return [String] Sensor annotation
      def annotation
        redis.get(desc_key)
      end

      # Cleans up all sensor metadata in Redis
      def cleanup
        redis.del(desc_key)
        cleanup_dump
      end
  
      # Processes event
      # @param value [Object] value produced by some kind of event
      def event(value)
        process_event(value)
        true
      rescue StandardError => e
        false
      end

      protected
      
      # Forms Redis key to store annotation
      def desc_key
        "pulse_meter:desc:#{name}"
      end
      
      # For a block
      # @yield Executes it within Redis multi
      def multi
        redis.multi do
          yield
        end
      end

      private

      def process_event(value)
        # do nothing here
      end

    end
  end
end
