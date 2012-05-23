module PulseMeter
  module Visualize
    module DSL
      WIDGETS = %w(pie spline line area)
      DEFAULT_HIGHCHART_OPTIONS = {}

      class Page
        def initialize(title = nil)
          @title = title || ""
          @widgets = []
          @highchart_options = DEFAULT_HIGHCHART_OPTIONS.dup
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

        def title(new_title)
          @title = new_title || ''
        end

        def highchart_options(options = {})
          @highchart_options.merge!(options)
        end

        def to_page
          args = {
            title: @title,
            widgets: @widgets.map(&:to_widget),
            highchart_options: @highchart_options
          }
          PulseMeter::Visualize::Page.new(args)
        end

      end
    end
  end
end

