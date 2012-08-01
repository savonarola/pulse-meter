module PulseMeter
  module Sensor
    # Constructs multiple sensors from configuration passed 
    class Configuration
      include PulseMeter::Mixins::Utils
      include Enumerable

      # @!attribute [r] sensors
      #   @return [Hash] hash of sensors with names as keys and sensors as values 
      attr_reader :sensors

      # Initializes sensors
      # @param opts [Hash] sensors' configuration
      def initialize(opts = {})
        @sensors = {}
        opts.each do |name, opts|
          add_sensor(name, opts)
        end
      end

      # Adds sensor
      # @param name [Symbol] sensor name
      # @param opts [Hash] sensor options
      def add_sensor(name, opts)
        sensor_type = opts.respond_to?(:sensor_type) ? opts.sensor_type : opts[:sensor_type]
        klass_s = sensor_class(sensor_type)
        klass = constantize(klass_s)
        raise ArgumentError, "#{klass_s} is not a valid class for a sensor" unless klass
        args = (opts.respond_to?(:args) ? opts.args : opts[:args]) || {}
        @sensors[name.to_s] = klass.new(name, symbolize_keys(args.to_hash))
      end

      # Returns previously initialized sensor by name
      # @param name [Symbol] sensor name
      # @return [Sensor] sensor 
      def sensor(name)
        @sensors[name.to_s]
      end

      # Iterates over each sensor
      def each
        @sensors.each_value do |sensor|
          yield(sensor)
        end
      end

      # Invokes event for any sensor 
      # @raise [ArgumentError] unless sensor exists
      def method_missing(name, *args)
        name = name.to_s
        if @sensors.has_key?(name)
          @sensors[name].event(*args)
        elsif (name =~ /^(.*)_at$/) && @sensors.has_key?($1) 
          @sensors[$1].event_at(*args)
        else
          raise ArgumentError, "Unknown sensor: `#{name}'"
        end
      end

      protected

      def sensor_class(sensor_type)
        entries = sensor_type.to_s.split('/').map do |entry|
          entry.split('_').map(&:capitalize).join
        end
        entries.unshift('PulseMeter::Sensor').join('::')
      end

    end
  end
end
