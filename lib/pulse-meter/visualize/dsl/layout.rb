module PulseMeter
  module Visualize
    module DSL
      class Layout
        DEFAULT_REDRAW_INTERVAL = 0
        DEFAULT_TITLE = "Pulse Meter"

        def initialize
          @pages = []
          @title = DEFAULT_TITLE
          @redraw_interval = DEFAULT_REDRAW_INTERVAL
        end

        def title(title)
          @title = title
        end

        def redraw_interval(interval)
          @redraw_interval = interval
        end

        def page(title, &block)
          page = PulseMeter::Visualize::DSL::Page.new(title)
          yield(page)
          @pages << page
        end

        def dashboard(&block)
          page = PulseMeter::Visualize::DSL::Page.new
          yield(page)
          @dashboard = page
        end

        def to_layout
          pages = @pages.map(&:to_page)
          title = @title || ''
          dashboard = if @dashboard
            @dashboard.to_page
          else
            nil
          end
          redraw_interval = @redraw_interval || 0
          PulseMeter::Visualize::Layout.new( {
            pages: pages,
            title: title,
            dashboard: dashboard,
            redraw_interval: redraw_interval
          } )
        end

      end
    end
  end
end

