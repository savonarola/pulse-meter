module PulseMeter
  module Visualize
    module DSL
      class Widget < Base

        hash_extender :gchart_options
       
        int_setter :redraw_interval do |int|
          raise BadWidgetRedrawInterval, int unless int > 0
        end
        
        int_setter :width do |w|
          raise BadWidgetWidth, w unless w > 0 && w <= 10
        end

        dsl_array_extender :sensors, :sensor, PulseMeter::Visualize::DSL::Sensor

        def method_missing(name, value)
          gchart_options(name => value)
        end

      end
    end
  end
end

