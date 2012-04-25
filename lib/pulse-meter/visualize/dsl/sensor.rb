module PulseMeter
  module Visualize
    module DSL
      class Sensor

        attr_reader :name

        def initialize(name)
          @name = name 
        end

        def process_args(args) 
          @args = args
        end

      end
    end
  end
end


