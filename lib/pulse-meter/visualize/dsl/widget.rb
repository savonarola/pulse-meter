module PulseMeter
  module Visualize
    module DSL

      class Widget

        attr_reader :name

        def initialize(name)
          @name = name 
          @sensors = {}
        end

        def process_args(args) 
          if args[:sensor]
            s = PulseMeter::Visualize::DSL::Sensor.new(args[:sensor])
            @sensors = { s.name => s }
          end
        end

        def sensor(name, sensor_args = nil) 
          s = PulseMeter::Visualize::DSL::Sensor.new(name)
          s.process_args(sensor_args) if sensor_args
          @sensors[s.name] = s
        end

      end
    end
  end
end

