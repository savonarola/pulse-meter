$: << File.join(File.absolute_path(__FILE__), '..', '..', 'lib')

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

  sleep(Random.rand / 10)
end
