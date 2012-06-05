$: << File.join(File.absolute_path(__FILE__), '..', 'lib')

require "pulse-meter"

PulseMeter.redis = Redis.new

cfg = PulseMeter::Sensor::Configuration.new(
  lama_count: {
    type: 'timelined/counter',
    args: {
      annotation: 'Lama Count',
      interval: 10,
      ttl: 3600
    }
  },

  lama_average_age: {
    type: 'timelined/average',
    args: {
      annotation: 'Lama Average Age',
      interval: 20,
      ttl: 3600
    }
  },

  rhino_count: {
    type: 'timelined/counter',
    args: {
      annotation: 'Rhino Count',
      interval: 10,
      ttl: 3600
    }
  },

  goose_count: {
    type: 'timelined/hashed_counter',
    args: {
      annotation: 'Goose Count',
      interval: 10,
      ttl: 3600
    }
  },

  rhino_average_age: {
    type: 'timelined/average',
    args: {
      annotation: 'Rhino average age',
      interval: 20,
      ttl: 3600
    }
  }
)

while true
  sleep(Random.rand)
  STDERR.puts "tick"
  cfg.lama_count(1)
  cfg.rhino_count(2)
  cfg.lama_average_age(Random.rand(50))
  cfg.rhino_average_age(Random.rand(100))

  10.times do
    goose_n = Random.rand(4)
    cfg.goose_count("goose_#{goose_n}" => 1)
  end
end