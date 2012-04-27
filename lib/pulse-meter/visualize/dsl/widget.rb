module PulseMeter
  module Visualize
    module DSL
      class Widget
        include PulseMeter::Mixins::Utils

        DEFAULT_WIDTH = 100

        def initialize(type, name)
          raise BadWidgetType, type if type.to_s.empty?
          raise BadWidgetName, name if name.to_s.empty?
          @name = name 
          @title = titleize(name)
          @width = DEFAULT_WIDTH
          @sensors = []
        end

        def process_args(args) 
          if args[:sensor]
            s = PulseMeter::Visualize::DSL::Sensor.new(args[:sensor])
            @sensors = [s]
          end
          if args[:title]
            @title = args[:title]
          end
          if args[:width]
            @width = args[:width]
          end
        end

        def title(new_title)
          @title = new_title || ''
        end

        def width(new_width)
          raise BadWidgetWidth, new_width unless new_width.respond_to?(:to_i)
          w = new_width.to_i
          raise BadWidgetWidth, new_width unless w > 0 && w <= 100
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
            name: @name,
            width: @width,
            sensors: @sensors.map(&:to_sensor)
          }
          PulseMeter::Visualize::Widget.new(args)
        end
      end
    end
  end
end

