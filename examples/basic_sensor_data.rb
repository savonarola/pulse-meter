$: << File.join(File.absolute_path(__FILE__), '..', 'lib')

require "pulse-meter"
            
PulseMeter.redis = Redis.new

cfg = PulseMeter::Sensor::Configuration.new(
  lama_count: {
    sensor_type:'timelined/counter',
    args: {
      annotation: 'Lama Count',
      interval: 10,
      ttl: 3600
    }
  },

  lama_count_1min: {
    sensor_type:'timelined/counter',
    args: {
      annotation: 'Lama Count (1 min)',
      interval: 60,
      ttl: 3600
    }
  },

  lama_average_age: {
    sensor_type:'timelined/average',
    args: {
      annotation: 'Lama Average Age',
      interval: 20,
      ttl: 3600
    }
  },

  rhino_count: {
    sensor_type:'timelined/counter',
    args: {
      annotation: 'Rhino Count',
      interval: 10,
      ttl: 3600
    }
  },

  goose_count: {
    sensor_type:'timelined/hashed_counter',
    args: {
      annotation: 'Goose Count',
      interval: 10,
      ttl: 3600
    }
  },

  rhino_average_age: {
    sensor_type:'timelined/average',
    args: {
      annotation: 'Rhino average age',
      interval: 20,
      ttl: 3600
    }
  },

  sensor_without_annotation: {
    sensor_type:'timelined/average',
    args: {
      interval: 20,
      ttl: 3600
    }
  },

  cpu: {sensor_type: 'indicator'},
  memory: {sensor_type: 'indicator'},
  temperature: {
    sensor_type: 'hashed_indicator',
    args: {
      annotation: 'T'
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
    cfg.goose_count("g_#{goose_n}" => 1)
    cfg.temperature("g_#{goose_n}" => Random.rand(50))
  end

  cfg.cpu(Random.rand(100))
  cfg.memory(Random.rand(100))
end
