module PulseMeter
  module Sensor
    class Configuration
      include PulseMeter::Mixins::Utils

      def initialize(opts = {})
        @sensors = {}
        opts.each do |name, opts|
          add_sensor(name, opts)
        end
      end

      def add_sensor(name, opts)
        type = opts.respond_to?(:type) ? opts.type : opts[:type]
        klass_s = sensor_class(type)
        klass = constantize(klass_s)
        raise ArgumentError, "#{klass_s} is not a valid class for a sensor" unless klass
        args = (opts.respond_to?(:args) ? opts.args : opts[:args]) || {}
        @sensors[name.to_s] = klass.new(name, symbolize_keys(args.to_hash))
      end

      def sensor(name)
        @sensors[name.to_s]
      end

      def method_missing(name, *args)
        name = name.to_s
        if @sensors.has_key?(name)
          @sensors[name].event(*args)
        else
          raise ArgumentError, "Unknown sensor: `#{name}'"
        end
      end

      protected

      def sensor_class(type)
        entries = type.to_s.split('/').map do |entry|
          entry.split('_').map(&:capitalize).join
        end
        entries.unshift('PulseMeter::Sensor').join('::')
      end


    end
  end
end