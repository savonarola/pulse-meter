module PulseMeter
  module Visualize
    module DSL
      class Error < StandardError; end      

      class NoWidgets < Error; end

      class BadSensorName < Error
        def initialize(name)
          super("Bad sensor name: `#{name}'")
        end
      end

      class BadWidgetName < Error
        def initialize(name)
          super("Bad widget name: `#{name}'")
        end
      end

      class BadWidgetWidth < Error
        def initialize(width)
          super("Bad widget width: `#{width}'")
        end
      end

      class BadWidgetRedrawInterval < Error
        def initialize(redraw_interval)
          super("Bad widget redraw_interval: `#{redraw_interval}'")
        end
      end

      class BadWidgetTimeSpan < Error
        def initialize(timespan)
          super("Bad widget timespan: `#{timespan}'")
        end
      end
    end
  end
end

