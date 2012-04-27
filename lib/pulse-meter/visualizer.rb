require 'pulse-meter'

# DSL

require 'pulse-meter/visualize/dsl/sensor'
require 'pulse-meter/visualize/dsl/widget'
require 'pulse-meter/visualize/dsl/page'
require 'pulse-meter/visualize/dsl/layout'

# Visualize

require 'pulse-meter/visualize/sensor'
require 'pulse-meter/visualize/widget'
require 'pulse-meter/visualize/layout'
require 'pulse-meter/visualize/page'

module PulseMeter
  class Visualizer
    def self.draw(&block) 
      layout_cofigurator = PulseMeter::Visualize::DSL::Layout.new
      layout_cofigurator.instance_eval &block
      layout_cofigurator.to_layout
    end
  end
end
