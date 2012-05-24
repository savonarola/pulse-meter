$: << File.join(File.absolute_path(__FILE__), '..', 'lib')

require "pulse-meter/visualizer"

PulseMeter.redis = Redis.new

layout = PulseMeter::Visualizer.draw do |l|

  l.title "Minimal App"

  l.page "Main Page" do |p|
    p.area "Live Counter",
      sensor: :simple_sample_counter,
      timespan: 5 * 60,
      redraw_interval: 1
  end

end

run layout.to_app