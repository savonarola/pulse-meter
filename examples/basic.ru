$: << File.join(File.absolute_path(__FILE__), '..', 'lib')

require 'pulse-meter/visualizer'

PulseMeter.redis = Redis.new

layout = PulseMeter::Visualizer.draw do |l|

  l.title "WunderZoo Stats"

  l.page "Counts" do |p|

    p.spline "Lama count", sensor: :lama_count do |c|
      c.redraw_interval 5
      c.values_label 'Count'
      c.width 5
      c.show_last_point true
      c.timespan 120
    end

    p.spline "Rhino count", sensor: :rhino_count do |c|
      c.redraw_interval 5
      c.values_label 'Count'
      c.width 5
      c.show_last_point true
      c.timespan 120
    end

    p.spline "Rhino & Lama count comparison" do |c|
      c.redraw_interval 5
      c.values_label 'Count'
      c.width 5
      c.show_last_point true
      c.timespan 120

      c.sensor :rhino_count
      c.sensor :lama_count
    end

    p.pie "Rhino & Lama count comparison" do |c|
      c.redraw_interval 5
      c.values_label 'Count'
      c.width 5
      c.show_last_point true
      c.timespan 120

      c.sensor :rhino_count
      c.sensor :lama_count
    end

  end

  l.page "Ages" do |p|

    p.spline "Lama average age", sensor: :lama_average_age do |c|
      c.redraw_interval 5
      c.values_label 'Age'
      c.width 5
      c.show_last_point true
      c.timespan 120
    end

    p.spline "Rhino average age", sensor: :rhino_average_age do |c|
      c.redraw_interval 5
      c.values_label 'Age'
      c.width 5
      c.show_last_point true
      c.timespan 120
    end

    p.spline "Rhino & Lama average age comparison" do |c|
      c.redraw_interval 5
      c.values_label 'Age'
      c.width 5
      c.show_last_point true
      c.timespan 120

      c.sensor :lama_average_age
      c.sensor :rhino_average_age
    end

    p.pie "Rhino & Lama average age comparison" do |c|
      c.redraw_interval 5
      c.values_label 'Age'
      c.width 5
      c.show_last_point true
      c.timespan 120

      c.sensor :lama_average_age
      c.sensor :rhino_average_age
    end

  end

  l.use_utc false
end

run layout.to_app
