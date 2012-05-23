require "redis"
require "pulse-meter/version"
require "pulse-meter/mixins/dumper"
require "pulse-meter/mixins/utils"
require "pulse-meter/server"
require "pulse-meter/sensor"
require "pulse-meter/client/manager"

module PulseMeter
  @@configuration = nil

  class << self
    def send(sensor_name, value = nil)
      sensor = configuration.sensor(sensor_name)
      raise "Cannot find sensor: #{sensor_name}" unless sensor

      if sensor.remote
        Client::Manager.find_for_sensor(sensor_name).send(sensor_name, value)
      else
        sensor.create.event(value)
      end
    end

    def configuration=(configuration)
      @@configuration = configuration
    end

    def configuration
      @@configuration
    end

    def sensor(name)
      configuration.sensor(name)
    end

    def redis
      PulseMeter::Client::Manager.find configuration.default_client
    end

    def client(name)
      configuration.client(name)
    end
  end
end
