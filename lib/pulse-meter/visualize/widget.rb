module PulseMeter
  module Visualize
    class Widget
      attr_reader :sensors
      attr_reader :title
      attr_reader :type
      attr_reader :width

      def initialize(args) 
        raise ArgumentError unless args.respond_to?('[]')
        @title = args[:title] or raise ArgumentError, ":title not specified"
        @sensors = args[:sensors] or raise ArgumentError, ":sensors not specified"
        @type = args[:type] or raise ArgumentError, ":type not specified"
        @width = args[:width]
      end
    end
  end
end

