module PulseMeter
  module Sensor
    module Timelined
      class Median < Percentile

        def initialize(name, options)
          super(name, options.merge({:p => 0.5}))
        end

      end
    end
  end
end
