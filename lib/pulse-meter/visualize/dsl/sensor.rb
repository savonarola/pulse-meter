module PulseMeter
  module Visualize
    module DSL
      class Sensor
        def initialize(name)
          @args = {:sensor => name}
        end

        def process_args(args) 
          @args.merge!(args)
        end

        def to_sensor
          PulseMeter::Visualize::Sensor.new(@args)
        end
      end
    end
  end
end


