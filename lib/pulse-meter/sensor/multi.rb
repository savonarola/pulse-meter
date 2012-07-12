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
        @configuration_options = options[:configuration]
        raise ArgumentError, "configuration option missing" unless @configuration_options
      end

      def event(factors_hash, value)
        ensure_valid_factors!(factors_hash)

        each_factors_combination do |combination|
          factor_values = factor_values_for_combination(combination, factors_hash)
          sensor = get_or_create_sensor(combination, factor_values)
          sensor.event(value)
        end
      end

      def self.flush!
        @@sensors = PulseMeter::Sensor::Configuration.new
      end

      protected

      def get_or_create_sensor(factor_names, factor_values)
        name = get_sensor_name(factor_names, factor_values)
        sensor(name) || sensors.add_sensor(name, configuration_options)
      end

      def ensure_valid_factors!(factors_hash)
        factors.each do |factor_name|
          unless factors_hash.has_key?(factor_name)
            raise ArgumentError, "Value of factor #{factor_name} missing"
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

      def get_sensor_name(factor_names, factor_values)
        sensor_name = name.to_s
        unless factor_names.empty?
          factor_names.zip(factor_values).each do |n, v|
            sensor_name << "_#{n}_#{v}"
          end
        end
        sensor_name.to_sym
      end

    end
  end
end
