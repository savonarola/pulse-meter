# Visualize

require 'pulse_meter/visualize/base'
require 'pulse_meter/visualize/sensor'
require 'pulse_meter/visualize/widget'
require 'pulse_meter/visualize/widgets/timeline'
require 'pulse_meter/visualize/widgets/pie'
require 'pulse_meter/visualize/widgets/gauge'
require 'pulse_meter/visualize/page'
require 'pulse_meter/visualize/layout'

# DSL

require 'pulse_meter/visualize/dsl/errors'
require 'pulse_meter/visualize/dsl/base'
require 'pulse_meter/visualize/dsl/sensor'
require 'pulse_meter/visualize/dsl/widget'
require 'pulse_meter/visualize/dsl/widgets/area'
require 'pulse_meter/visualize/dsl/widgets/line'
require 'pulse_meter/visualize/dsl/widgets/pie'
require 'pulse_meter/visualize/dsl/widgets/table'
require 'pulse_meter/visualize/dsl/widgets/gauge'
require 'pulse_meter/visualize/dsl/page'
require 'pulse_meter/visualize/dsl/layout'

# App

require 'pulse_meter/visualize/app'

module PulseMeter
  class Visualizer
    def self.draw(&block)
      layout_cofigurator = PulseMeter::Visualize::DSL::Layout.new
      yield(layout_cofigurator)
      layout_cofigurator.to_data
    end
  end
end
