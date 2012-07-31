module PulseMeter
  module Visualize
    class Layout < Base
      def initialize(opts)
        super
        @opts[:pages] ||= []
        @opts[:gchart_options] ||= {}
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
					use_utc: use_utc,
          gchart_options: gchart_options
        }
      end

      def widget(page_id, widget_id, opts = {})
        pages[page_id].widget_data(widget_id, opts)
      end

      def widgets(page_id)
        pages[page_id].widget_datas
      end

      def sensor_list
        PulseMeter::Sensor::Base
          .list_objects
          .select{|s| s.is_a?(PulseMeter::Sensor::Timeline)}
          .map do |s|
          {
            id: s.name,
            annotation: s.annotation,
            type: s.class.to_s.split('::').last,
            interval: s.interval
          }
        end
      end

    end
  end
end
