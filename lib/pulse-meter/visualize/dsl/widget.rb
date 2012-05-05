module PulseMeter
  module Visualize
    module DSL
      class Widget
        include PulseMeter::Mixins::Utils

        DEFAULT_WIDTH = 10

        def initialize(type, title = '')
          raise BadWidgetType, type if type.to_s.empty?
          @type = type
          @title = title.to_s || ''
          @values_label = ''
          @width = DEFAULT_WIDTH
          @sensors = []
        end

        def process_args(args) 
          if args[:sensor]
            sensor(args[:sensor])
          end
          if args[:title]
            title(args[:title])
          end
          if args[:width]
            width(args[:width])
          end
          if args[:values_label]
            values_label(args[:values_label])
          end
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
            sensors: @sensors.map(&:to_sensor)
          }
          PulseMeter::Visualize::Widget.new(args)
        end
      end
    end
  end
end

