module PulseMeter
  module Visualize
    class Layout
      attr_reader :pages

      attr_reader :title
      attr_reader :use_utc
      attr_reader :gchart_options

      def initialize(args) 
        raise ArgumentError unless args.respond_to?('[]')
        @title = args[:title] or raise ArgumentError, ":title not specified"
        @pages = args[:pages] or raise ArgumentError, ":pages not specified"
        @use_utc = args[:use_utc]
        @gchart_options = args[:gchart_options]
      end

      def to_app
        PulseMeter::Visualize::App.new(self)
      end

			def page_infos
				res = []
				pages.each_with_index do |p, i|
					res << {
						id: i + 1,
						title: p.title,
            gchart_options: p.gchart_options
					}
				end
				res
			end

			def options
				{
					use_utc: @use_utc,
          gchart_options: @gchart_options
        }
      end

      def widget(page_id, widget_id, opts = {})
        pages[page_id].widget_data(widget_id, opts)
      end

      def widgets(page_id)
        pages[page_id].widget_datas
      end

    end
  end
end
