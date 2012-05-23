module PulseMeter
  module Visualize
    class Sensor
      attr_reader :name
      attr_reader :color

      def initialize(args)
        raise ArgumentError unless args.respond_to?('[]')
        @name = args[:sensor] or raise ArgumentError, ":sensor_name not specified"
        @color = args[:color]
      end

      def last_value(need_incomplete=false)
        sensor = real_sensor

        sensor_data = if need_incomplete
          sensor.timeline(sensor.interval).first
        else
          sensor.timeline(sensor.interval * 2).first
        end

        if sensor_data.is_a?(PulseMeter::SensorData)
          sensor_data.value
        else
          nil
        end
      end

      def last_point_data(need_incomplete=false)
        res = {
            name: real_sensor.annotation,
            y: last_value(need_incomplete)
        }
        res[:color] = color if color
        res
      end

      def timeline_data(time_span, need_incomplete = false)
        sensor = real_sensor
        data = sensor.timeline(time_span).map{|sd| {x: sd.start_time.to_i*1000, y: sd.value}}
        data.pop unless need_incomplete
        res = {
            name: sensor.annotation,
            data: data
        }
        res[:color] = color if color
        res
      end

      protected

      def real_sensor
        # TODO add !temporarily! caching if this will be called too frequently
        PulseMeter::Sensor::Base.restore(@name)
      end

    end
  end
end

