module PulseMeter
  module Visualize
    module DSL
      module Widgets
        class Pie < PulseMeter::Visualize::DSL::Widget
          self.data_class = PulseMeter::Visualize::Widgets::Pie

          string_setter :values_label
          bool_setter :show_last_point

        end
      end
    end
  end
end

