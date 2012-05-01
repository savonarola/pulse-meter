$: << File.join(File.absolute_path(__FILE__), '..', 'lib')

require 'pulse-meter/visualizer'

layout = PulseMeter::Visualizer.draw do |l|

  l.title "My Gauges"

  l.dashboard do |d|
    d.chart :convertion do |c|
      c.sensor :adv_clicks, color: :green
      c.sensor :adv_shows, color: :red
    end

    d.pie :agents, title: 'User Agents' do |c|
      c.sensor :agent_ie
      c.sensor :agent_chrome
      c.sensor :agent_ff
      c.sensor :agent_other
    end

  end

  l.page "Page 1" do |p|
    p.chart :rph_total, sensor: :rph_total
  end

  l.page "Page 2" do |p|
    p.chart :rph_main_page, sensor: :rph_main_page
  end

  l.page "Page 3" do |p|
    p.chart :request_time_p95_hour
  
    p.pie :success_vs_fail_total_hourly do |w|
      w.sensor :success_total_hourly
      w.sensor :fail_total_hourly
    end

  end

  l.redraw_interval 10
end

run layout.to_app
