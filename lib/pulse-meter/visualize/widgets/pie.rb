module PulseMeter
  module Visualize
    module Widgets
      class Pie < PulseMeter::Visualize::Widget

        def data(options = {})
          super().merge({
            series: slice_data
          })
        end

        protected
        
        def slice_data
          values = []
          slice_options = []
          now = Time.now
          sensors.each do |s|
            s.last_point_data(now, show_last_point).each do |point_data|
              values << [point_data[:name], point_data[:y]]
              slice_options << {color: point_data[:color]}
            end
          end
          {
            data: values,
            options: slice_options
          }
        end

      end
    end

  end
end


