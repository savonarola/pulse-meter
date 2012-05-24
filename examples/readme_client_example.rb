$: << File.join(File.absolute_path(__FILE__), '..', 'lib')

require 'pulse-meter'
PulseMeter.redis = Redis.new

# static sensor examples

counter = PulseMeter::Sensor::Counter.new :my_counter
counter.event(1)
counter.event(2)
puts counter.value

indicator = PulseMeter::Sensor::Indicator.new :my_value
indicator.event(3.14)
indicator.event(2.71)
puts indicator.value

hashed_counter = PulseMeter::Sensor::HashedCounter.new :my_h_counter
hashed_counter.event(:x => 1)
hashed_counter.event(:y => 5)
hashed_counter.event(:y => 1)
p hashed_counter.value


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