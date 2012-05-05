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

      class BadWidgetType < Error
        def initialize(type)
          super("Bad widget type: `#{type}'")
        end
      end

      class BadWidgetWidth < Error
        def initialize(width)
          super("Bad widget width: `#{width}'")
        end
      end
    end
  end
end

