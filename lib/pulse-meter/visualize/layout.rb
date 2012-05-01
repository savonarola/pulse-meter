module PulseMeter
  module Visualize
    class Layout
      attr_reader :pages
      attr_reader :dashboard

      attr_reader :title
      attr_accessor :redraw_interval

      def initialize(args) 
        raise ArgumentError unless args.respond_to?('[]')
        @title = args[:title] or raise ArgumentError, ":title not specified"
        @dashboard = args[:dashboard]
        @pages = args[:pages] or raise ArgumentError, ":pages not specified"
        @redraw_interval = args[:redraw_interval] or raise ArgumentError, ":redraw_interval not specified"
      end

      def to_app
        PulseMeter::Visualize::App.new(self)
      end

			def page_titles
				res = []
				pages.each_with_index do |p, i|
					res << {
						id: i,
						title: p.title
					}
				end
				res
			end
	
    end
  end
end
