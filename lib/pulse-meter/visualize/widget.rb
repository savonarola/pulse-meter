module PulseMeter
  module Visualize
    class Error < StandardError; end

    class Widget
      class NotATimelinedSensorInWidget < PulseMeter::Visualize::Error; end
      class DifferentSensorIntervalsInWidget < PulseMeter::Visualize::Error; end

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

      def data(options = {})
        ensure_sensor_match!
        real_timespan = options[:timespan] || timespan
        {
          title: title,
          type: type,
          values_title: values_label,
          width: width,
          interval: redraw_interval,
          series: series_data(real_timespan),
          timespan: timespan
        }
      end

      protected

      def series_data(tspan)
        case type
          when :line
            line_series_data(tspan)
          when :area
            line_series_data(tspan)
          when :pie
            pie_series_data
        end
      end

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

      def line_series_data(tspan)
        now = Time.now
        sensor_datas = sensors.map{ |s|
          s.timeline_data(now, tspan, show_last_point)
        }
        rows = []
        titles = []
        series_options = []
        datas = []
        sensor_datas.each do |sensor_data|
          sensor_data.each do |tl|
            titles << tl[:name]
            series_options << {color: tl[:color]}
            datas << tl[:data]
          end
        end
        unless datas.empty?
          first = datas.shift
          first.each_with_index do |tl_data, row_num|
            rows << datas.each_with_object([tl_data[:x], tl_data[:y]]) do |data_col, row|
              row << data_col[row_num][:y]
            end
          end
        end
        {
          titles: titles,
          rows: rows,
          options: series_options
        }
      end

      def pie_series_data
        values = []
        slice_options = []
        now = Time.now
        sensors.each do |s|
          s.last_point_data(now, show_last_point).each do |point_data|
            values << [point_data[:name], point_data[:y]]
            slice_options << {color: point_data[:color]}
          end
        end
        {
          data: values,
          options: slice_options
        }
      end

    end
  end
end

