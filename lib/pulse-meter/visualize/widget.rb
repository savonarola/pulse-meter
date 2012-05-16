module PulseMeter
  module Visualize
    class Widget
      attr_reader :sensors
      attr_reader :title
      attr_reader :type
      attr_reader :width
      attr_reader :values_label
      attr_reader :show_last_point
      attr_reader :redraw_interval
      attr_reader :timespan

      def initialize(args) 
        raise ArgumentError unless args.respond_to?('[]')
        @title = args[:title] or raise ArgumentError, ":title not specified"
        @sensors = args[:sensors] or raise ArgumentError, ":sensors not specified"
        @type = args[:type] or raise ArgumentError, ":type not specified"
        @width = args[:width]
        @values_label = args[:values_label]
        @show_last_point = args[:show_last_point] || false
        @redraw_interval = args[:redraw_interval]
        @timespan = args[:timespan]
      end

      def data
        {
          title: title,
          type: type,
          values_title: values_label,
          width: width,
          interval: redraw_interval,
          series: series_data
        }
      end

      protected

      def series_data
        case type
          when :spline
            line_series_data
          when :line
            line_series_data
          when :pie
            pie_series_data
        end
      end

      def line_series_data
        sensors.map do |s|
          s.timeline_data(timespan, show_last_point)
        end
      end

      def pie_series_data
        [{
          type: type,
          name: values_label,
          data: sensors.map{|s| s.last_point_data(show_last_point)}
        }]
      end

    end
  end
end

