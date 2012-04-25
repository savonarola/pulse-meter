module PulseMeter
  module Visualize
    module DSL
      WIDGETS = {
        :pie => PulseMeter::Visualize::DSL::Pie,
        :chart => PulseMeter::Visualize::DSL::Chart
      }

      class Layout

        def initialize
          @widgets = {}
          WIDGETS.keys.each{|k| @widgets[k] = {}}
          @pages = []
        end

        def title(title)
          @title = title
        end

        def redis(redis)
          @redis = redis
        end

        def widget(type, name, args, &block)
          w = @widgets[type][name] ||= WIDGETS[type].new(name)
          w.process_args(args) if args
          w.instance_eval &block if block_given?
        end

        WIDGETS.keys.each do |wtype|
          class_eval <<-EVAL
            def #{wtype}(name, args = nil, &block)
              widget(:#{wtype}, name, args, &block)
            end
          EVAL
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

      end
    end
  end
end

