module PulseMeter
  module Visualize
    module DSL
      class Sensor
        def initialize(name)
          @name = name 
        end

        def process_args(args) 
          @args.merge!(args)
        end

        def to_sensor
          @args ||= {}
          PulseMeter::Visualize::Sensor.new(@args.merge(:sensor => @name))
        end

      end
    end
  end
end


