$: << File.join(File.absolute_path(__FILE__), '..', '..', 'lib')

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
