$: << File.join(File.absolute_path(__FILE__), '..', 'lib')

require "pulse-meter/visualizer"

PulseMeter.redis = Redis.new

layout = PulseMeter::Visualizer.draw do |l|

  # Application title
  l.title "Full Example"

  # Use local time for x-axis of charts
  l.use_utc false

  # Transfer some global parameters to Google Charts
  l.gchart_options({
    background_color: '#CCC'
  })

  # Add some pages
  l.page "Request count" do |p|

    # Add chart  (of Google Charts `area' style, `pie' and `line' are also available)
    p.area "Requests per minute" do |w|

      # Plot :requests_per_minute values on this chart with black color
      w.sensor :requests_per_minute, color: '#000000'

      # Plot :errors_per_minute values on this chart with red color
      w.sensor :errors_per_minute, color: '#FF0000'

      # Plot values for the last hour
      w.timespan 60 * 60

      # Redraw chart every 10 seconds
      w.redraw_interval 10

      # Plot incomplete data
      w.show_last_point true

      # Meaning of the y-axis
      w.values_label "Request count"

      # Occupy half (5/10) of the page (horizontally)
      w.width 5

      # Transfer page-wide (and page-specific) options to Google Charts
      p.gchart_options({
        height: 500
      })
    end

    p.area "Requests per hour" do |w|

      w.sensor :requests_per_hour, color: '#555555'
      w.sensor :errors_per_hour, color: '#FF0000'

      w.timespan 24 * 60 * 60
      w.redraw_interval 10
      w.show_last_point true
      w.values_label "Request count"
      w.width 5

    end
  end

  l.page "Request times" do |p|
    p.area "Requests time" do |w|

      w.sensor :longest_minute_request
      w.sensor :shortest_minute_request
      w.sensor :perc90_minute_request

      w.timespan 60 * 60
      w.redraw_interval 10
      w.show_last_point true
      w.values_label "Time in seconds"
      w.width 10

    end
  end

  l.page "Browsers" do |p|
    p.pie "Requests from browser" do |w|

      [:ie, :firefox, :chrome, :other].each do |sensor|
        w.sensor sensor
      end

      w.redraw_interval 10
      w.show_last_point true
      w.values_label "Request count"
      w.width 10

    end

    p.gchart_options({
      height: 500
    })
  end

end

run layout.to_app
