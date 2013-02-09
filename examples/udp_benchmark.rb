$:.unshift File.expand_path('../../lib/', __FILE__)

require "pulse-meter"

PulseMeter.redis = Redis.new
PulseMeter.redis.flushdb
PulseMeter.command_aggregator = PulseMeter::CommandAggregator::UDP.new([['127.0.0.1', 33333], ['127.0.0.1', 33334], ['127.0.0.1', 33335],])

ss = PulseMeter::Sensor::Configuration.new(
  cnt: {sensor_type: 'counter'}
)

start = Time.now.to_f

i = 0
loop do
  i += 1 
  ss.cnt(1)
  sleep 0.000005
  if i % 1000 == 0
    t = Time.now.to_f
    passed = t - start
    required_rps = i.to_f / passed
    val = ss.sensor(:cnt){|s| s.value}
    actual_rps = val.to_f / passed
    p [i, required_rps, val, actual_rps]
  end
end

