module PulseMeter
  module Sensor
    # Constructs multiple sensors from configuration passed 
    class Configuration
      include PulseMeter::Mixins::Utils
      include Enumerable

      # Initializes sensors
      # @param opts [Hash] sensors' configuration
      def initialize(opts = {})
        @opts = opts
      end

      # Returns previously initialized sensor by name
      # @param name [Symbol] sensor name
      # @yield [sensor] Gives sensor(if it is found) to the block
      def sensor(name)
        raise ArgumentError, "need a block" unless block_given?
        with_resque do
          s = sensors[name.to_s]
          yield(s) if s
        end
      end

      # Returns true value if sensor with specified name exists in configuration, false otherwise
      # @param name [Symbol] sensor name
      def has_sensor?(name)
        has_sensor = false
        with_resque do
          has_sensor = sensors.has_key?(name)
        end
        has_sensor
      end

      # Adds sensor
      # @param name [Symbol] sensor name
      # @param opts [Hash] sensor options
      def add_sensor(name, opts)
        with_resque do
          sensors[name.to_s] = create_sensor(name, opts)
        end
      end

      # Iterates over each sensor
      def each
        with_resque do
          sensors.each_value do |s|
            yield(s)
          end
        end
      end

      # Invokes event(_at) for any sensor 
      # @raise [ArgumentError] unless sensor exists
      def method_missing(name, *args)
        with_resque do
          name = name.to_s
          if sensors.has_key?(name)
            sensors[name].event(*args)
          elsif name =~ /\A(.*)_at\z/
            sensor_name = $1
            sensors[sensor_name].event_at(*args) if sensors.has_key?(sensor_name) 
          end
        end
      end

      private

      def with_resque
        yield
      rescue StandardError => e
        PulseMeter.error "Configuration error: #{e}, #{e.backtrace.join("\n")}"
        nil
      end


      # Tries to create a specific sensor
      # @param name [Symbol] sensor name
      # @param opts [Hash] sensor options
      def create_sensor(name, opts)
        sensor_type = opts.respond_to?(:sensor_type) ? opts.sensor_type : opts[:sensor_type]
        klass_s = sensor_class(sensor_type)
        klass = constantize(klass_s)
        raise ArgumentError, "#{klass_s} is not a valid class for a sensor" unless klass
        args = (opts.respond_to?(:args) ? opts.args : opts[:args]) || {}
        klass.new(name, symbolize_keys(args.to_hash))
      end

      def sensor_class(sensor_type)
        entries = sensor_type.to_s.split('/').map do |entry|
          entry.split('_').map(&:capitalize).join
        end
        entries.unshift('PulseMeter::Sensor').join('::')
      end

      # Lazy collection of sensors, specified by opts
      # @raise [ArgumentError] unless one of the sensors exists
      def sensors
        @sensors ||= @opts.each_with_object({}){ |(name, opts), sensor_acc|
          sensor_acc[name.to_s] = create_sensor(name, opts)
        }
      end

    end
  end
end
