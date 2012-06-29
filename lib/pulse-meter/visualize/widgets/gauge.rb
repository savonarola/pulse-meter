module PulseMeter
  module Visualize
    module Widgets
      class Gauge < PulseMeter::Visualize::Widget
        class NotAnIndicatorSensorInGaugeWidget < PulseMeter::Visualize::Error; end

        def data(options = {})
          super().merge({
            series: values_data
          })
        end

        protected

        def ensure_gauge_indicators!
          sensors.each do |s|
            unless s.type <= PulseMeter::Sensor::Indicator
              raise NotAnIndicatorSensorInGaugeWidget, "Sensor #{s.name} is not an indicator(PulseMeter::Sensor::Indicator)"
            end
          end
        end
        
        def values_data
          ensure_gauge_indicators!
          sensors.map do |s|
            [s.annotation, s.value]
          end
        end

      end
    end

  end
end


