module PulseMeter
  module Visualize
    module DSL
      class Layout

        def initialize
          @widgets = {}
          @ordered_widgets = []
          WIDGETS.keys.each{|k| @widgets[k] = {}}
          @pages = []
        end

        def title(title)
          @title = title
        end

        def redraw_interval(interval)
          @redraw_interval = interval
        end

        def page(title, &block)
          page = PulseMeter::Visualize::DSL::Page.new(title, widgets: @widgets)
          page.instance_eval &block
          @pages << page
        end

        def dashboard(&block)
          page = PulseMeter::Visualize::DSL::Page.new('', widgets: @widgets)
          page.instance_eval &block
          @dashboard = page
        end

        def to_layout
          pages = @pages.map(&:to_page)
          title = @title || ''
          dashboard = if @dashboard
            @dashboard.to_page
          else
            raise PulseMeter::Visualize::NoWidgets if @ordered_widgets.empty?
            dashboard_page = PulseMeter::Visualize::DSL::Page.new('', widgets: @widgets)
            @ordered_widgets.each{ |(type, name)| dashboard_page.widget(type, name)}
            dashboard_page.to_page
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

