shared_context :dsl do
  include_context :configuration
end

shared_context :configuration do
  PulseMeter.configuration = PulseMeter::Configuration::DSL.new do
    remote do
      client :udp do
        host "localhost"
        port 1234
      end

      client :invalid_udp do
        host "ololo"
        port 1234
      end

      sensor :invalid_udp_sensor do
        client :invalid_udp
      end

      sensor :udp_sensor do
        client :udp
      end
    end

    client :first, :default => true do
      host "localhost"
      port 1234
    end

    sensor :a_sensor => PulseMeter::Sensor::Timelined::Counter do
      ttl 1000
      interval 100
      annotation 'A'
      client :first
    end

    sensor :b_sensor => PulseMeter::Sensor::Timelined::Counter do
      ttl 1000
      interval 100
      annotation 'B'
      client :first
    end

    sensor :sensor_name => PulseMeter::Sensor::Timelined::Median do
      client :first
    end
  end
end
