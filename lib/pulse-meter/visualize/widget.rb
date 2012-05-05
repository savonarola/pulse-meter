module PulseMeter
  module Visualize
    class Widget
      attr_reader :sensors
      attr_reader :title
      attr_reader :type
      attr_reader :width
      attr_reader :values_label
      attr_reader :show_last_point
      attr_reader :redraw_interval
      attr_reader :timespan

      def initialize(args) 
        raise ArgumentError unless args.respond_to?('[]')
        @title = args[:title] or raise ArgumentError, ":title not specified"
        @sensors = args[:sensors] or raise ArgumentError, ":sensors not specified"
        @type = args[:type] or raise ArgumentError, ":type not specified"
        @width = args[:width]
        @values_label = args[:values_label]
        @show_last_point = args[:show_last_point] || false
        @redraw_interval = args[:redraw_interval]
        @timespan = args[:timespan]
      end
    end
  end
end

