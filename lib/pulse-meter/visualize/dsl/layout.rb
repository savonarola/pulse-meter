module PulseMeter
  module Visualize
    module DSL
      class Layout
        DEFAULT_TITLE = "Pulse Meter"
        DEFAULT_GCHART_OPTIONS = {}

        def initialize
          @pages = []
          @title = DEFAULT_TITLE
          @use_utc = true
          @gchart_options = DEFAULT_GCHART_OPTIONS.dup
        end

        def title(title)
          @title = title
        end

        def use_utc(use = true)
          @use_utc = use
        end

        def outlier_color(_)
          STDERR.puts "DEPRECATION: outlier_color DSL helper does not take effect anymore"
        end

        def highchart_options(_)
          STDERR.puts "DEPRECATION: highchart_options DSL helper does not take effect anymore, use gchart_options instead"
        end

        def gchart_options(options = {})
          @gchart_options.merge!(options)
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
            gchart_options: @gchart_options
          } )
        end

      end
    end
  end
end

