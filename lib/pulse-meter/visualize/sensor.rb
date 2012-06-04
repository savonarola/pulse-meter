require "pulse-meter/visualize/series_extractor"

module PulseMeter
  module Visualize
    class Sensor
      attr_reader :name
      attr_reader :color

      def initialize(args) 
        raise ArgumentError unless args.respond_to?('[]')
        @name = args[:sensor] or raise ArgumentError, ":sensor not specified"
        @color = args[:color]
      end

      def last_value(need_incomplete=false)
        sensor = real_sensor

        sensor_data = if need_incomplete
          sensor.timeline(sensor.interval).first
        else
          sensor.timeline(sensor.interval * 2).first
        end

        if sensor_data.is_a?(PulseMeter::SensorData)
          sensor_data.value
        else
          nil
        end
      end

      def last_point_data(need_incomplete=false)
        extractor.point_data(last_value(need_incomplete))
      end

      def timeline_data(time_span, need_incomplete = false)
        sensor = real_sensor
        timeline_data = sensor.timeline(time_span)
        timeline_data.pop unless need_incomplete
        extractor.series_data(timeline_data)
      end

      def annotation
        real_sensor.annotation
      end

      def type
        real_sensor.class
      end

      def extractor
        PulseMeter::Visualize.extractor(self)
      end

      protected

      def real_sensor
        # TODO add !temporarily! caching if this will be called too frequently
        PulseMeter::Sensor::Base.restore(@name)
      end


    end
  end
end

