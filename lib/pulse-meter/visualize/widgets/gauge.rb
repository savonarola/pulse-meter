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
            unless s.type <= PulseMeter::Sensor::Indicator || s.type <= PulseMeter::Sensor::HashedIndicator
              raise NotAnIndicatorSensorInGaugeWidget, "Sensor #{s.name} is not an indicator(PulseMeter::Sensor::Indicator or PulseMeter::Sensor::HashedIndicator)"
            end
          end
        end
        
        def values_data
          ensure_gauge_indicators!
          gauges = []
          sensors.map do |s|
            s_type = s.type
            case 
            when s_type == PulseMeter::Sensor::Indicator
              gauges << [s.annotation, s.value]
            when s_type == PulseMeter::Sensor::HashedIndicator
              s.value.each_pair do |k, v|
                gauge_title = "#{s.annotation}: #{k}"
                gauges << [gauge_title, v]
              end
            end
          end
          gauges
        end

      end
    end

  end
end


