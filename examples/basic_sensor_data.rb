$: << File.join(File.absolute_path(__FILE__), '..', 'lib')

require "pulse-meter"

PulseMeter.redis = Redis.new

lama_counter = PulseMeter::Sensor::Timelined::Counter.new(:lama_count,
  annotation: 'Lama Count',
  interval: 10,
  ttl: 3600
)

lama_average_age = PulseMeter::Sensor::Timelined::Average.new(:lama_average_age,
  annotation: 'Lama Average Age',
  interval: 20,
  ttl: 3600
)

rhino_counter = PulseMeter::Sensor::Timelined::Counter.new(:rhino_count,
  annotation: 'Rhino Count',
  interval: 10,
  ttl: 3600
)

rhino_average_age = PulseMeter::Sensor::Timelined::Average.new(:rhino_average_age,
  annotation: 'Rhino average age',
  interval: 20,
  ttl: 3600
)

while true
  sleep(Random.rand)
  STDERR.puts "tick"
  lama_counter.event(1)
  rhino_counter.event(2)
  lama_average_age.event(Random.rand(50))
  rhino_average_age.event(Random.rand(100))
end