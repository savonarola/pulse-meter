module PulseMeter
  module Visualize
    module DSL
      WIDGETS = %w(pie chart)

      class Page
        def initialize(title)
          @title = title || ""
          @widgets = []
        end

        def widget(type, name, widget_args = nil, &block) 
          w = PulseMeter::Visualize::DSL::Widget.new(type, name)
          w.process_args(widget_args) if widget_args
          w.instance_eval &block if block_given?
          @widgets << w
        end

        WIDGETS.each do |wtype|
          class_eval <<-EVAL
            def #{wtype}(name, args = nil, &block)
              widget(:#{wtype}, name, args, &block)
            end
          EVAL
        end

        def to_page
          args = {
            title: @title,
            widgets: @widgets.map(&:to_widget)            
          }
          PulseMeter::Visualize::Page.new(args)
        end

      end
    end
  end
end

