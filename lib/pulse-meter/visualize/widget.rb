module PulseMeter
  module Visualize
    class Error < StandardError; end

    class Widget < Base
      def initialize(opts)
        super
        @opts[:sensors] ||= []
      end

      def data
        {
          type: type,
          title: title,
          redraw_interval: redraw_interval,
          width: width,
          gchart_options: gchart_options,
          values_title: values_label
        }
      end

      def type
        self.class.to_s.split('::').last.downcase
      end

      protected

      def ensure_sensor_match!
        intervals = []
        sensors.each do |s|
          unless s.type < PulseMeter::Sensor::Timeline
            raise NotATimelinedSensorInWidget, "sensor `#{s.name}' is not timelined"
          end
          intervals << s.interval
        end

        unless intervals.all?{|i| i == intervals.first}
          interval_notice = sensors.map{|s| "#{s.name}: #{s.interval}"}.join(', ')
          raise DifferentSensorIntervalsInWidget, "Sensors with different intervals in a single widget: #{interval_notice}"
        end
      end


      def gauge_series_data
        ensure_gauge_indicators!
        sensors.map do |s|
          [s.annotation, s.value]
        end
      end

    end
  end
end

