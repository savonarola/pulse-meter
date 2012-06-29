require 'pulse-meter'

# Visualize

require 'pulse-meter/visualize/base'
require 'pulse-meter/visualize/sensor'
require 'pulse-meter/visualize/widget'
require 'pulse-meter/visualize/widgets/timeline'
require 'pulse-meter/visualize/widgets/pie'
require 'pulse-meter/visualize/widgets/gauge'
require 'pulse-meter/visualize/page'
require 'pulse-meter/visualize/layout'

# DSL

require 'pulse-meter/visualize/dsl/errors'
require 'pulse-meter/visualize/dsl/base'
require 'pulse-meter/visualize/dsl/sensor'
require 'pulse-meter/visualize/dsl/widget'
require 'pulse-meter/visualize/dsl/widgets/area'
require 'pulse-meter/visualize/dsl/widgets/line'
require 'pulse-meter/visualize/dsl/widgets/pie'
require 'pulse-meter/visualize/dsl/widgets/table'
require 'pulse-meter/visualize/dsl/widgets/gauge'
require 'pulse-meter/visualize/dsl/page'
require 'pulse-meter/visualize/dsl/layout'

# App

require 'pulse-meter/visualize/app'

module PulseMeter
  class Visualizer
    def self.draw(&block)
      layout_cofigurator = PulseMeter::Visualize::DSL::Layout.new
      yield(layout_cofigurator)
      layout_cofigurator.to_data
    end
  end
end
