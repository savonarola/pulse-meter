module PulseMeter
  module Sensor
    class Multi
      include PulseMeter::Mixins::Utils

      attr_reader :name
      attr_reader :factors
      attr_reader :configuration_options

      @@sensors = PulseMeter::Sensor::Configuration.new

      def sensors
        @@sensors
      end

      def sensor(name)
        @@sensors.sensor(name)
      end

      def initialize(name, options)
        @name = name
        @factors = assert_array!(options, :factors)
        @configuration_options = 
          options[:configuration] || 
          raise ArgumentError, "configuration option missing"
      end

      def event(factors_hash, value)
        ensure_valid_factors!(factors_hash)

        each_factors_combination do |combination|
          factor_values = factor_values_for_combination(combination, factors_hash)
          sensor = get_or_create_sensor(factor_values)
          sensor.event(value)
        end
      end

      def get_or_create_sensor(factor_values)
        name = get_sensor_name(factor_values)
        sensor(name) || sensors.add_sensor(name, configuration_options)
      end

      def ensure_valid_factors!(factors_hash)
        factors_hash.keys.each do |factor|
          unless factors.include?(factor)
            raise ArgumentError, "Value of factor #{factor} missing"
          end
        end
      end

      def each_factors_combination
        each_subset(factors) do |combination|
          yield(combination)
        end
      end

      def factor_values_for_combination(combination, factors_hash)
        combination.each_with_object([]) do |k, acc|
          acc << factors_hash[k]
        end
      end

      def get_sensor_name(factor_values)
        "#{name}_" + factor_values.join("_")
      end

    end
  end
end
