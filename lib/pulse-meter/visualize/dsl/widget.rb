module PulseMeter
  module Visualize
    module DSL
      class Widget
        include PulseMeter::Mixins::Utils

        DEFAULT_WIDTH = 10
        DEFAULT_TIMESPAN = 60 * 60 * 24 # One day

        def initialize(type, title = '')
          raise BadWidgetType, type if type.to_s.empty?
          @type = type
          @title = title.to_s || ''
          @values_label = ''
          @width = DEFAULT_WIDTH
          @sensors = []
          @show_last_point = false
          @redraw_interval = nil
          @timespan = DEFAULT_TIMESPAN
        end

        def process_args(args)
          [:sensor, :title, :width, :values_label, :show_last_point, :redraw_interval, :timespan].each do |arg|
            if args.has_key?(arg)
              send(arg, args[arg])
            end
          end
        end

        def redraw_interval(new_redraw_interval)
          new_redraw_interval = new_redraw_interval.to_i
          raise BadWidgetRedrawInterval, new_redraw_interval unless new_redraw_interval > 0
          @redraw_interval = new_redraw_interval
        end

        def show_last_point(new_show_last_point)
          @show_last_point = !!new_show_last_point
        end

        def timespan(new_timespan)
          new_timespan = new_timespan.to_i
          raise BadWidgetTimeSpan, new_timespan unless new_timespan > 0
          @timespan = new_timespan
        end

        def values_label(new_label)
          @values_label = new_label.to_s
        end

        def title(new_title)
          @title = new_title.to_s || ''
        end

        def width(new_width)
          raise BadWidgetWidth, new_width unless new_width.respond_to?(:to_i)
          w = new_width.to_i
          raise BadWidgetWidth, new_width unless w > 0 && w <= 10
          @width = new_width.to_i
        end

        def sensor(name, sensor_args = nil) 
          s = PulseMeter::Visualize::DSL::Sensor.new(name)
          s.process_args(sensor_args) if sensor_args
          @sensors << s
        end

        def to_widget
          args = {
            title: @title,
            type: @type,
            values_label: @values_label,
            width: @width,
            sensors: @sensors.map(&:to_sensor),
            redraw_interval: @redraw_interval,
            show_last_point: @show_last_point,
            timespan: @timespan
          }
          PulseMeter::Visualize::Widget.new(args)
        end
      end
    end
  end
end

