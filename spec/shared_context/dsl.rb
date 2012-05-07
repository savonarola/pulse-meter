shared_context :dsl do
  include_context :configuration
  after { sensor.cleanup }
end

shared_context :configuration do
  PulseMeter.configuration = PulseMeter::Configuration::DSL.new do
    remote do
      client :udp do
        host "udp-host"
        port 1234
      end

      sensor :udp_sensor do
        client :udp
        ttl 10
      end
    end

    client :first do
      host "localhost"
      port 1234
    end

    sensor :sensor_name => PulseMeter::Sensor::Timelined::Median do
      client :first
    end
  end
end
