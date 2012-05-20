module PulseMeter
  module Visualize
    module DSL
      class Layout
        DEFAULT_TITLE = "Pulse Meter"
        DEFAULT_OUTLIER_COLOR = "#FF0000"
        DEFAULT_HIGHCHART_OPTIONS = {}

        def initialize
          @pages = []
          @title = DEFAULT_TITLE
          @use_utc = true
          @outlier_color = DEFAULT_OUTLIER_COLOR
          @highchart_options = DEFAULT_HIGHCHART_OPTIONS.dup
        end

        def title(title)
          @title = title
        end

        def use_utc(use = true)
          @use_utc = use
        end

        def outlier_color(color)
          @outlier_color = color
        end

        def highchart_options(options = {})
          @highchart_options.merge!(options)
        end

        def page(title, &block)
          page = PulseMeter::Visualize::DSL::Page.new(title)
          yield(page)
          @pages << page
        end

        def to_layout
          pages = @pages.map(&:to_page)
          title = @title || ''
          PulseMeter::Visualize::Layout.new( {
            pages: pages,
            title: title,
            use_utc: @use_utc,
            outlier_color: @outlier_color,
            highchart_options: @highchart_options
          } )
        end

      end
    end
  end
end

