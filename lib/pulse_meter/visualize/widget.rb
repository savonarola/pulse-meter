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

      def gauge_series_data
        ensure_gauge_indicators!
        sensors.map do |s|
          [s.annotation, s.value]
        end
      end

    end
  end
end

