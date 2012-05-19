module PulseMeter
  module Visualize
    module DSL
      class Layout
        DEFAULT_TITLE = "Pulse Meter"

        def initialize
          @pages = []
          @title = DEFAULT_TITLE
          @use_utc = true
        end

        def title(title)
          @title = title
        end

        def use_utc(use = true)
          @use_utc = use
        end

        def outlier_color(color = '#FF000')
          @outlier_color = color
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
            outlier_color: @outlier_color
          } )
        end

      end
    end
  end
end

