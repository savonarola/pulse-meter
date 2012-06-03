module PulseMeter
  module Visualize
    class Layout
      attr_reader :pages

      attr_reader :title
      attr_reader :use_utc
      attr_reader :outlier_color
      attr_reader :highchart_options

      def initialize(args) 
        raise ArgumentError unless args.respond_to?('[]')
        @title = args[:title] or raise ArgumentError, ":title not specified"
        @pages = args[:pages] or raise ArgumentError, ":pages not specified"
        @use_utc = args[:use_utc]
        @outlier_color = args[:outlier_color]
        @highchart_options = args[:highchart_options]
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
            highchart_options: p.highchart_options
					}
				end
				res
			end

			def options
				{
					use_utc: @use_utc,
				  outlier_color: @outlier_color,
          highchart_options: @highchart_options
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
