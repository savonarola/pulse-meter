$: << File.join(File.absolute_path(__FILE__), '..', 'lib')

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

