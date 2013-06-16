module PulseMeter
  module Visualize
    module DSL
      module Widgets
        class Gauge < PulseMeter::Visualize::DSL::Widget
          self.data_class = PulseMeter::Visualize::Widgets::Gauge
        end
      end
    end
  end
end

