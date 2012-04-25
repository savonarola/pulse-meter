require 'pulse-meter'

require 'pulse-meter/visualize/dsl/widget'
require 'pulse-meter/visualize/dsl/pie'
require 'pulse-meter/visualize/dsl/chart'

require 'pulse-meter/visualize/dsl/layout'
require 'pulse-meter/visualize/dsl/page'

require 'pulse-meter/visualize/dsl/sensor'

module PulseMeter
  class Visualizer
    def self.draw(&block) 
      layout = PulseMeter::Visualize::DSL::Layout.new
      layout.instance_eval &block
      layout
    end
  end
end
