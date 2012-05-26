$: << File.join(File.absolute_path(__FILE__), '..', '..', 'lib')

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
