module PulseMeter
  module Visualize
    class Sensor
      attr_reader :name

      def initialize(args) 
        raise ArgumentError unless args.respond_to?('[]')
        @name = args[:sensor] or raise ArgumentError, ":sensor_name not specified"
        @color = args[:color]
      end

      def timeline(ago)
        sensor = real_sensor
        return nil unless sensor
        res = { 
          :interval => sensor.interval,
          :name => name,
          :values => sensor.timeline(ago)
        }
        res[:color] = @color if @color
        res
      end

      protected

      def real_sensor
        # TODO add caching if this will be called too frequently
        PulseMeter::Sensor::Base.restore(@name)
      rescue RestoreError
        nil
      end

    end
  end
end

