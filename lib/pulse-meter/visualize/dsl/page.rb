module PulseMeter
  module Visualize
    module DSL
      WIDGETS = %w(pie line area table gauge)
      DEFAULT_GCHART_OPTIONS = {}

      class Page
        def initialize(title = nil)
          @title = title || ""
          @widgets = []
          @gchart_options = DEFAULT_GCHART_OPTIONS.dup
        end

        def widget(type, title = '', widget_args = nil, &block) 
          w = PulseMeter::Visualize::DSL::Widget.new(type, title)
          w.process_args(widget_args) if widget_args
          yield(w) if block_given?
          @widgets << w
        end

        WIDGETS.each do |wtype|
          class_eval <<-EVAL
            def #{wtype}(title = '', args = nil, &block)
              widget(:#{wtype}, title, args, &block)
            end
          EVAL
        end

        def spline(*args, &block)
          STDERR.puts "DEPRECATION: spline widget is no longer available. Using `line' as a fallback."
          line(*args, &block)
        end

        def title(new_title)
          @title = new_title || ''
        end

        def highchart_options(_)
          STDERR.puts "DEPRECATION: highchart_options DSL helper does not take effect anymore, use gchart_options instead"
        end

        def gchart_options(options = {})
          @gchart_options.merge!(options)
        end

        def to_page
          args = {
            title: @title,
            widgets: @widgets.map(&:to_widget),
            gchart_options: @gchart_options
          }
          PulseMeter::Visualize::Page.new(args)
        end

      end
    end
  end
end

