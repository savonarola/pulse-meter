require "pulse-meter/visualize/series_extractor"

module PulseMeter
  module Visualize
    class Sensor < Base
      def last_value(now, need_incomplete=false)
        sensor = real_sensor

        sensor_data = if need_incomplete
          sensor.timeline_within(now - sensor.interval, now).first
        else
          sensor.timeline_within(now - sensor.interval * 2, now).first
        end

        if sensor_data.is_a?(PulseMeter::SensorData)
          sensor_data.value
        else
          nil
        end
      end

      def last_point_data(now, need_incomplete=false)
        extractor.point_data(last_value(now, need_incomplete))
      end

      def timeline_data(now, time_span, need_incomplete = false)
        sensor = real_sensor
        timeline_data = sensor.timeline_within(now - time_span, now)
        timeline_data.pop unless need_incomplete
        extractor.series_data(timeline_data)
      end

      def annotation
        real_sensor.annotation || ''
      end

      def type
        real_sensor.class
      end

      def interval
        real_sensor.interval
      end
      
      def value
        real_sensor.value
      end

      def extractor
        PulseMeter::Visualize.extractor(self)
      end

      protected

      def real_sensor
        # TODO add !temporarily! caching if this will be called too frequently
        PulseMeter::Sensor::Base.restore(name)
      end

    end
  end
end

