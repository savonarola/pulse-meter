module PulseMeter
  module Visualize
    module Widgets
      class Error < StandardError; end
      class Timeline < PulseMeter::Visualize::Widget

        class NotATimelinedSensorInWidget < PulseMeter::Visualize::Error; end
        class DifferentSensorIntervalsInWidget < PulseMeter::Visualize::Error; end

        DEFAULT_TIMESPAN = 3600

        def initialize(opts)
          super
          opts[:timespan] ||= DEFAULT_TIMESPAN
        end

        def data(options = {})
          real_timespan = options[:timespan] || timespan
          super().merge({
            values_title: values_label,
            series: series_data(real_timespan),
            timespan: timespan,
            interval: interval
          })
        end

        protected

        def series_data(tspan)
          ensure_sensor_match!
          now = Time.now
          sensor_datas = sensors.map{ |s|
            s.timeline_data(now, tspan, show_last_point)
          }
          rows = []
          titles = []
          series_options = []
          datas = []
          sensor_datas.each do |sensor_data|
            sensor_data.each do |tl|
              titles << tl[:name]
              series_options << {color: tl[:color]}
              datas << tl[:data]
            end
          end
          unless datas.empty?
            first = datas.shift
            first.each_with_index do |tl_data, row_num|
              rows << datas.each_with_object([tl_data[:x], tl_data[:y]]) do |data_col, row|
                row << data_col[row_num][:y]
              end
            end
          end
          {
            titles: titles,
            rows: rows,
            options: series_options
          }
        end

        def ensure_sensor_match!
          intervals = []
          sensors.each do |s|
            unless s.type < PulseMeter::Sensor::Timeline
              raise NotATimelinedSensorInWidget, "sensor `#{s.name}' is not timelined"
            end
            intervals << s.interval
          end

          unless intervals.all?{|i| i == intervals.first}
            interval_notice = sensors.map{|s| "#{s.name}: #{s.interval}"}.join(', ')
            raise DifferentSensorIntervalsInWidget, "Sensors with different intervals in a single widget: #{interval_notice}"
          end
        end

        def interval
          if sensors.empty?
            nil
          else
            sensors.first.interval
          end
        end

      end

      class Area < Timeline; end
      class Line < Timeline; end
      
      class Table < Timeline 
        def data(options = {})
          res = super(options)      
          res[:series].delete(options)
          res
        end
      end
    end
  end
end

