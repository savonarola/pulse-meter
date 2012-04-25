module PulseMeter
  module Visualize
    module DSL
      class Page
        def initialize(title, args)
          @all_widgets = args[:widgets] || {}
          @title = title
          @widgets = []
        end

        def widget(type, name, widget_args = nil, &block) 
          w = if @all_widgets[type] && @all_widgets[type][name] 
            @all_widgets[type][name]
          else
            PulseMeter::Visualize::DSL::WIDGETS[type].new(name)
          end

          w.process_args(widget_args) if widget_args
          w.instance_eval &block if block_given?
          @widgets << w
          @all_widgets[w.name] = w
        end

        PulseMeter::Visualize::DSL::WIDGETS.keys.each do |wtype|
          class_eval <<-EVAL
            def #{wtype}(name, args = nil, &block)
              widget(:#{wtype}, name, args, &block)
            end
          EVAL
        end

      end
    end
  end
end

