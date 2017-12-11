![PulseMeter](https://raw.githubusercontent.com/savonarola/pulse-meter/master/PulseMeterLogo.png)

[![Gem Version](https://badge.fury.io/rb/pulse-meter.svg)](http://badge.fury.io/rb/pulse-meter)
[![Build Status](https://secure.travis-ci.org/savonarola/pulse-meter.svg)](http://travis-ci.org/savonarola/pulse-meter)
[![Dependency Status](https://gemnasium.com/badges/github.com/savonarola/pulse-meter.svg)](https://gemnasium.com/github.com/savonarola/pulse-meter)

# PulseMeter

PulseMeter is a gem for fast and convenient realtime aggregating of software internal stats through Redis. **This gem itself does not contain any code, it contains examples and bundles dependencies with real PulseMeter features.**

## Live Demo

A small live demo is located here: [pulse-meter.rubybox.ru](http://pulse-meter.rubybox.ru), its source code can be found here: [https://github.com/savonarola/pulse-meter-demo](https://github.com/savonarola/pulse-meter-demo)

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

```ruby
PulseMeter.redis = Redis.new
sensor = PulseMeter::Sensor::Counter.new :my_counter
sensor.event(5)
...
sensor.event(3)
```

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
  * Indicator
  * Hashed counter
  * Hashed indicator
  * Max value
  * Min value
  * Multifactor sensor
  * Median value
  * Percentile
  * MultiPercentile
  * Unique counter

There are several caveats with timeline sensors:

  * The value of a sensor for the last interval (which is not finished yet) is often not very useful.
    When building a visualisation you may choose to display the last value or not.
  * For some sensors (currently Median and Percentile) considerable amount of data should be stored for a
    particular interval to obtain value for this interval. So it is a good idea to schedule
    `pulse reduce`
    command on a regular basis. This command reduces the stored data for passed intervals to single values,
    so that they do not consume storage space.

### Observers

Observer allows to notify sensors each time some class or instance method is called
Suppose you have a user model and want to count users distribution by name. To do this you have to observe class method `create` of User class:

```ruby
sensors = PulseMeter::Sensor::Configuration.new(
  users_by_name: {sensor_type: 'hashed_counter'}
)
PulseMeter::Observer.observe_class_method(User, :create, sensors) do |execution_time, attrs|
  users_by_name({attrs[:name] => 1})
end
```
    
Each time the observed method is called, the block recieves all method's arguments prepended with method's execution time. Block is executed in context of the receiver object passed to observer (this means that `users_by_name` method refers to `sensors`).    
One should use `observe_method` to observe instance methods.

`unobserve_class_method` and `unobserve_method` remove observations from class or instace method.

## Command line interface

Gem includes a tool `pulse`, which allows to send events to sensors, list them, etc.
You should pay attention to the command `pulse reduce`, which is generally should be
scheduled on a regular basis to keep data in Redis small.

To see available commands of this tool one can run the example above(see `examples/readme_client_example.rb`)
and run `pulse help`.


## Client usage

Just create sensor objects and write data. Some examples below.

```ruby
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
```

Note: if you're using simple counters (for example, `timelined/counter` or `timelined/hashed_counter`) you may just set `raw_data_ttl` parameter equal to `ttl`, then sensor data will persist for the set period even without running `pulse reduce` periodically.
```ruby
requests_per_minute = PulseMeter::Sensor::Timelined::Counter.new(:my_t_counter,
  interval: 60,
  ttl: 7.days,
  raw_data_ttl: 7.days
)
```
 
 There is also an alternative and a bit more DRY way for sensor creation, management and usage using `PulseMeter::Sensor::Configuration` class. It is also convenient for creating a bunch of sensors from some configuration data. Using and creating sensors through `PulseMeter::Sensor::Configuration` also allows to ignore any i/o errors (i.e. redis server unavailability), and this is generally the required case. 
 
```ruby
require 'pulse-meter'
PulseMeter.redis = Redis.new

sensors = PulseMeter::Sensor::Configuration.new(
  my_counter: {sensor_type: 'counter'},
  my_value: {sensor_type: 'indicator'},
  my_h_counter: {sensor_type: 'hashed_counter'},
  my_t_counter: {
    sensor_type: 'timelined/counter',
    args: {
      interval: 60,         # count for each minute
      ttl: 24 * 60 * 60     # keep data one day
    }
  },
  my_t_max: {
    sensor_type: 'timelined/max',
    args: {
      interval: 60,         # count for each minute
      ttl: 24 * 60 * 60     # keep data one day
    }
  }
)

sensors.my_counter(1)
sensors.my_counter(2)
sensors.sensor(:my_counter) do |s|
  puts s.value
end

sensors.my_value(3.14)
sensors.my_value(2.71)
sensors.sensor(:my_value) do |s|
  puts s.value
end
    

sensors.my_h_counter(:x => 1)
sensors.my_h_counter(:y => 5)
sensors.my_h_counter(:y => 1)
sensors.sensor(:my_h_counter) do |s|
  p s.value
end

sensors.my_t_counter(1)
sensors.my_t_counter(1)
sleep(60)
sensors.my_t_counter(1)
sensors.sensor(:my_t_counter) do |s|
  s.timeline(2 * 60).each do |v|
    puts "#{v.start_time}: #{v.value}"
  end
end

sensors.my_t_max(3)
sensors.my_t_max(1)
sensors.my_t_max(2)
sleep(60)
sensors.my_t_max(5)
sensors.my_t_max(7)
sensors.my_t_max(6)
sensors.sensor(:my_t_max) do |s|
  s.timeline(2 * 60).each do |v|
      puts "#{v.start_time}: #{v.value}"
  end
end
```

## Visualisation

PulseMeter comes with a simple DSL which allows to build a self-contained Rack application for
visualizing timeline sensor data.

The application is described by *Layout* which contains some general application options and a list of *Pages*.
Each page contain a list of *Widgets* (charts), and each widget is associated with several sensors, which produce
data series for the chart.

There is a minimal and a full example below.

### Minimal example

It can be found in `examples/minimal` folder. To run it, execute
`bundle && cd examples/minimal && bundle exec foreman start` (or just `rake example:minimal`)
at project root and visit
`http://localhost:9292` at your browser.

`client.rb` just creates a timelined counter an sends data to it in an infinite loop.

```ruby
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
```

`server.ru` is a Rackup file creating a simple layout with one page and one widget on it, which displays
the sensor's data. The layout is converted to a rack application and launched.

```ruby
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
```

`Procfile` allows to launch both "client" script and the web server with `foreman`.

    web: bundle exec rackup server.ru
    sensor_data_generator: bundle exec ruby client.rb

### Full example with DSL explanation

It can be found in `examples/full` folder. To run it, execute
`bundle && cd examples/full && bundle exec foreman start` (or just `rake example:full`)
at project root and visit
`http://localhost:9292` at your browser.

`client.rb` imitating users visiting some imaginary site.

```ruby
require "pulse-meter"

PulseMeter.redis = Redis.new

sensors = PulseMeter::Sensor::Configuration.new(
  requests_per_minute: {
    sensor_type: 'timelined/counter',
    args: {
      annotation: 'Requests per minute',
      interval: 60,
      ttl: 60 * 60 * 24    # keep data one day
    }
  },
  requests_per_hour: {
    sensor_type: 'timelined/counter',
    args: {
      annotation: 'Requests per hour',
      interval: 60 * 60,
      ttl: 60 * 60 * 24 * 30    # keep data 30 days
    }
  },
  # when ActiveSupport extentions are loaded, a better way is to write just
  # :interval => 1.hour,
  # :ttl => 30.days
  errors_per_minute: {
    sensor_type: 'timelined/counter',
    args: {
      annotation: 'Errors per minute',
      interval: 60,
      ttl: 60 * 60 * 24
    }
  },
  errors_per_hour: {
    sensor_type: 'timelined/counter',
    args: {
      annotation: 'Errors per hour',
      interval: 60 * 60,
      ttl: 60 * 60 * 24 * 30
    }
  },
  longest_minute_request: {
    sensor_type: 'timelined/max',
    args: {
      annotation: 'Longest minute requests',
      interval: 60,
      ttl: 60 * 60 * 24
    }
  },
  shortest_minute_request: {
    sensor_type: 'timelined/min',
    args: {
      annotation: 'Shortest minute requests',
      interval: 60,
      ttl: 60 * 60 * 24
    }
  },
  perc90_minute_request: {
    sensor_type: 'timelined/percentile',
    args: {
      annotation: 'Minute request 90-percent percentile',
      interval: 60,
      ttl: 60 * 60 * 24,
      p: 0.9
    }
  },
  cpu: {
    sensor_type: 'indicator',
    args: {
      annotation: 'CPU%'
    }
  }
)

agent_names = [:ie, :firefox, :chrome, :other]
agent_names.each do |agent|
  sensors.add_sensor(agent,
    sensor_type: 'timelined/counter',
    args: {
      annotation: "Requests from #{agent} browser",
      interval: 60 * 60,
      ttl: 60 * 60 * 24 * 30
    }
  )
end

while true
  sensors.requests_per_minute(1)
  sensors.requests_per_hour(1)

  if Random.rand(10) < 1 # let "errors" sometimes occur
    sensors.errors_per_minute(1)
    sensors.errors_per_hour(1)
  end

  request_time = 0.1 + Random.rand

  sensors.longest_minute_request(request_time)
  sensors.shortest_minute_request(request_time)
  sensors.perc90_minute_request(request_time)

  agent_counter = sensors.sensor(agent_names.shuffle.first)
  agent_counter.event(1)

  sensors.cpu(Random.rand(100))

  sleep(Random.rand / 10)
end
```

A more complicated visualization

```ruby
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

  l.page "Gauge" do |p|

    p.gauge "CPU Load" do |g|
      g.redraw_interval 5
      g.values_label '%'
      g.width 5

      g.red_from 90
      g.red_to 100
      g.yellow_from 75
      g.yellow_to 90
      g.minor_ticks 5
      g.height 200

      g.sensor :cpu
    end

  end

end

run layout.to_app
```

## Rails app integration

If you're going to use this gem to visualize some metrics in your Rails app, you can do it in two ways.

1. First way: mount dashboard as rack-app. For this you need to write something like that:

    + define entry (for example in lib/)

    ```ruby
    # lib/dashboard.rb
    module Dashboard
      require 'pulse-meter/visualizer'
      class Panel
        def self.entry
          layout = PulseMeter::Visualizer.draw do |l|
            l.title "Метрики"
            l.use_utc false
            # l.outlier_color '#FF0000'
            l.page "Скоринг" do |p|

              p.area "Запросы" do |w|
                w.sensor :requests_count

                w.timespan 1.day
                w.redraw_interval 30.seconds
                w.show_last_point true
                w.values_label "Запросы"
                w.width 6
              end

            end
          end
          layout.to_app
        end
      end
    end
    ```

    + mount it in routes:

    ```ruby
    # config/routes.rb
    YourApp::Application.routes.draw do
    ...
      mount Dashboard::Panel.entry, at: '/dashboard'
    ...
    end
    ```

2. Second way is to integrate lib is to define dashboard in config.ru:

    + Write entry like in previous paragraph or right down in the config/application.rb

    + modify your config.ru as below:

    ```ruby
    # config.ru

    # This file is used by Rack-based servers to start the application.
    require ::File.expand_path('../config/environment',  __FILE__)

    map "/" do
      run RailsApp::Application
    end

    map "/dashboard" do
      run RailsApp::Dashboard::Panel.entry
    end
    ```

Don't forget to initialize redis database for `PulseMeter` and define sensors (using `config/settings.yml` and `PulseMeter::Sensor::Configuration` or somehow else).


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pulse-meter'
```

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
