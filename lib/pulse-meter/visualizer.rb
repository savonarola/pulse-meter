require 'pulse-meter'

# DSL

require 'pulse-meter/visualize/dsl/errors'
require 'pulse-meter/visualize/dsl/sensor'
require 'pulse-meter/visualize/dsl/widget'
require 'pulse-meter/visualize/dsl/page'
require 'pulse-meter/visualize/dsl/layout'

# Visualize

require 'pulse-meter/visualize/sensor'
require 'pulse-meter/visualize/widget'
require 'pulse-meter/visualize/layout'
require 'pulse-meter/visualize/page'

# App

require 'pulse-meter/visualize/app'

module PulseMeter
  class Visualizer
    def self.draw(&block)
      layout_cofigurator = PulseMeter::Visualize::DSL::Layout.new
      yield(layout_cofigurator)
      layout_cofigurator.to_layout
    end
  end
end
