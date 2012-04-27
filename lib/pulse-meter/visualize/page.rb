module PulseMeter
  module Visualize
    class Page
      attr_reader :widgets
      attr_reader :title

      def initialize(args) 
        raise ArgumentError unless args.respond_to?('[]')
        @title = args[:title] or raise ArgumentError, ":title not specified"
        @widgets = args[:widgets] or raise ArgumentError, ":widgets not specified"
      end
    end
  end
end

