[![Build Status](https://secure.travis-ci.org/savonarola/pulse-meter.png)](http://travis-ci.org/savonarola/pulse-meter)

# PulseMeter

PulseMeter is a gem for fast and convenient realtime aggregating of software internal stats through Redis.

## Features

PulseMeter is designed to provide the following features:

 * Simple deployment. The only infrastructure resource you are required to have is Redis.

 * Low resource consumption. Since different kinds of events are aggregated in Redis,
   you are as light and fast as Redis is.
   Event data is stored in constant space and expires over time.

 * Focus on the client. To start gathering some metrics, you should only modify your client: create a sensor object
   and send events to it. All aggregated data can be accessed immediately without any
   sort of "server reconfiguration"

## Concept

The fundamental concept of PulseMeter is *sensor*. Sensor is some named piece of data in Redis which
can be updated through client side objects associated with this data. The semantics of the data can be
different: some counter, value, series of values, etc. There is no need to care about explicit creation this data:
one just creates a client object and writes data to it, e.g.

    PulseMeter.redis = Redis.new
    sensor = PulseMeter::Sensor::Counter.new :my_counter
    sensor.event(5)
    ...
    sensor.event(3)

After that the value associated with the counter is immediately available (through CLI, for example). Any other
client can access the associated counter by creating object with the same redis db and sensor name.

Sensors can be divided into two large groups.

### Static sensors

These are just single values which can be read by CLI, e.g. some counter or some value
representing current state of a resource (current free memory amount, current la etc.). Currently, the
following static sensors are available:

  * Counter
  * Hashed Counter
  * Unique Counter
  * Indicator

They have no web visualisation interface and they are assumed to be used by external visualisation tools.


### Timeline sensors

These sensors are series of values, one value for each consequent time interval. They
are available by CLI and have web visualisation interface. Examples of such sensors include: count of
requests to some resource per hour, the longest request to a database per minute, etc.

The following timeline sensors are available:

  * Average value
  * Counter
  * Hashed counter
  * Max value
  * Min value
  * Median value
  * Percentile
  * Unique counter

There are several caveats with timeline sensors:

  * The value of a sensor for the last interval (which is not finished yet) is often not very useful.
    When building a visualisation you may choose to display the last value or not.
  * For some sensors (currently Median and Percentile) considerable amount of data should be stored for a
    particular interval to obtain value for this interval. So it is a good idea to schedule
    <tt>pulse reduce</tt>
    command on a regular basis. This command reduces the stored data for passed intervals to single values,
    so that they do not consume storage space.

## Client usage

Just create sensor objects and write data. Some examples below.

    require 'pulse-meter'
    PulseMeter.redis = Redis.new

    # static sensor examples

    counter = PulseMeter::Sensor::Counter.new :my_counter
    counter.event(1)
    counter.event(2)
    puts counter.value
    # prints
    # 3

    indicator = PulseMeter::Sensor::Indicator.new :my_value
    indicator.event(3.14)
    indicator.event(2.71)
    puts indicator.value
    # prints
    # 2.71

    hashed_counter = PulseMeter::Sensor::HashedCounter.new :my_h_counter
    hashed_counter.event(:x => 1)
    hashed_counter.event(:y => 5)
    hashed_counter.event(:y => 1)
    p hashed_counter.value
    # prints
    # {"x"=>1, "y"=>6}

    # timeline sensor examples

    requests_per_minute = PulseMeter::Sensor::Timelined::Counter.new(:my_t_counter,
      :interval => 60,         # count for each minute
      :ttl => 24 * 60 * 60     # keep data one day
    )
    requests_per_minute.event(1)
    requests_per_minute.event(1)
    sleep(60)
    requests_per_minute.event(1)
    requests_per_minute.timeline(2 * 60).each do |v|
      puts "#{v.start_time}: #{v.value}"
    end
    # prints somewhat like
    # 2012-05-24 11:06:00 +0400: 2
    # 2012-05-24 11:07:00 +0400: 1

    max_per_minute = PulseMeter::Sensor::Timelined::Max.new(:my_t_max,
      :interval => 60,         # max for each minute
      :ttl => 24 * 60 * 60     # keep data one day
    )
    max_per_minute.event(3)
    max_per_minute.event(1)
    max_per_minute.event(2)
    sleep(60)
    max_per_minute.event(5)
    max_per_minute.event(7)
    max_per_minute.event(6)
    max_per_minute.timeline(2 * 60).each do |v|
      puts "#{v.start_time}: #{v.value}"
    end
    # prints somewhat like
    # 2012-05-24 11:07:00 +0400: 3.0
    # 2012-05-24 11:08:00 +0400: 7.0

## Command line interface

Gem includes a tool <tt>pulse</tt>, which allows to send events to sensors, list them, etc.
You should pay attention to the command <tt>pulse reduce</tt>, which is generally should be
scheduled on a regular basis to keep data in Redis small.

To see available commands of this tool one can run the example above(see <tt>examples/readme\_client\_example.rb</tt>)
and run <tt>pulse help</tt>.

## Visualisation

PulseMeter comes with a simple DSL which allows to build a self-contained Rack application for
visualizing timeline sensor data.

The application is described by *Layout* which contains some general application options and a list of *Pages*.
Each page contain a list of *Widgets* (charts), and each widget is associated with several sensors, which produce
data series for the chart.

There is a minimal and a full example below.

### Minimal example

It can be found in <tt>examples/minimal</tt> folder. To run it, execute
<tt>bundle && cd examples/minimal && bundle exec foreman start</tt> (or just <tt>rake example:minimal</tt>)
at project root and visit
<tt>http://localhost:9292</tt> at your browser.

<tt>client.rb</tt> just creates a timelined counter an sends data to it in an infinite loop.

    require "pulse-meter"

    PulseMeter.redis = Redis.new

    sensor = PulseMeter::Sensor::Timelined::Counter.new(:simple_sample_counter,
      :interval => 5,
      :ttl => 60 * 60
    )

    while true
      STDERR.puts "tick"
      sensor.event(1)
      sleep(Random.rand)
    end

<tt>server.ru</tt> is a Rackup file creating a simple layout with one page and one widget on it, which displays
the sensor's data. The layout is converted to a rack application and launched.

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

<tt>Procfile</tt> allows to launch both "client" script and the web server with <tt>foreman</tt>.

    web: bundle exec rackup server.ru
    sensor_data_generator: bundle exec ruby client.rb

### Full example with DSL explanation

It can be found in <tt>examples/full</tt> folder. To run it, execute
<tt>bundle && cd examples/full && bundle exec foreman start</tt> (or just <tt>rake example:full</tt>)
at project root and visit
<tt>http://localhost:9292</tt> at your browser.

<tt>client.rb</tt> imitating users visiting some imaginary site

    require "pulse-meter"

    PulseMeter.redis = Redis.new

    requests_per_minute = PulseMeter::Sensor::Timelined::Counter.new(:requests_per_minute,
      :annotation => 'Requests per minute',
      :interval => 60,
      :ttl => 60 * 60 * 24    # keep data one day
    )

    requests_per_hour =  PulseMeter::Sensor::Timelined::Counter.new(:requests_per_hour,
      :annotation => 'Requests per hour',
      :interval => 60 * 60,
      :ttl => 60 * 60 * 24 * 30    # keep data 30 days
      # when ActiveSupport extentions are loaded, a better way is to write just
      # :interval => 1.hour,
      # :ttl => 30.days
    )

    errors_per_minute = PulseMeter::Sensor::Timelined::Counter.new(:errors_per_minute,
      :annotation => 'Errors per minute',
      :interval => 60,
      :ttl => 60 * 60 * 24
    )

    errors_per_hour =  PulseMeter::Sensor::Timelined::Counter.new(:errors_per_hour,
      :annotation => 'Errors per hour',
      :interval => 60 * 60,
      :ttl => 60 * 60 * 24 * 30
    )

    longest_minute_request = PulseMeter::Sensor::Timelined::Max.new(:longest_minute_request,
      :annotation => 'Longest minute requests',
      :interval => 60,
      :ttl => 60 * 60 * 24
    )

    shortest_minute_request = PulseMeter::Sensor::Timelined::Min.new(:shortest_minute_request,
      :annotation => 'Shortest minute requests',
      :interval => 60,
      :ttl => 60 * 60 * 24
    )

    perc90_minute_request = PulseMeter::Sensor::Timelined::Percentile.new(:perc90_minute_request,
      :annotation => 'Minute request 90-percent percentile',
      :interval => 60,
      :ttl => 60 * 60 * 24,
      :p => 0.9
    )

    agent_names = [:ie, :firefox, :chrome, :other]
    hour_agents = agent_names.each_with_object({}) do |agent, h|
      h[agent] = PulseMeter::Sensor::Timelined::Counter.new(agent,
        :annotation => "Requests from #{agent} browser",
        :interval => 60 * 60,
        :ttl => 60 * 60 * 24 * 30
      )
    end


    while true
      requests_per_minute.event(1)
      requests_per_hour.event(1)

      if Random.rand(10) < 1 # let "errors" sometimes occur
        errors_per_minute.event(1)
        errors_per_hour.event(1)
      end

      request_time = 0.1 + Random.rand

      longest_minute_request.event(request_time)
      shortest_minute_request.event(request_time)
      perc90_minute_request.event(request_time)

      agent_counter = hour_agents[agent_names.shuffle.first]
      agent_counter.event(1)

      sleep(Random.rand / 10)
    end

A more complicated visualization

    require "pulse-meter/visualizer"

    PulseMeter.redis = Redis.new

    layout = PulseMeter::Visualizer.draw do |l|

      # Application title
      l.title "Full Example"

      # Use local time for x-axis of charts
      l.use_utc false

      # Color for values cut off
      l.outlier_color '#FF0000'

      # Transfer some global parameters to Highcharts
      l.highchart_options({
        tooltip: {
          value_decimals: 2
        }
      })

      # Add some pages
      l.page "Request count" do |p|

        # Add chart  (of Highcharts `area' style, `spline', `pie' and `line' are also available)
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

          # Transfer page-wide (and page-specific) options to Highcharts
          p.highchart_options({
            chart: {
              height: 300
            }
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

          w.timespan 24 * 60 * 60
          w.redraw_interval 10
          w.show_last_point true
          w.values_label "Request count"
          w.width 10

        end

        p.highchart_options({
          chart: {
            height: 500
          }
        })
      end

    end

    run layout.to_app

## Installation

Add this line to your application's Gemfile:

    gem 'pulse-meter'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pulse-meter

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
