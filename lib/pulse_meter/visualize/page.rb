module PulseMeter
  module Visualize
    class Page < Base
      def initialize(opts)
        super
        @opts[:widgets] ||= []
        @opts[:gchart_options] ||= {}
      end

      def widget_data(widget_id, opts = {})
        widgets[widget_id].data(opts).merge(id: widget_id + 1)
      end

      def widget_datas
        res = []
        widgets.each_with_index do |w, i|
          res << w.data.merge(id: i + 1)
        end
        res
      end

    end
  end
end

