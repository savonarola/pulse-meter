require "pulse-meter/client/udp.rb"

module PulseMeter
  module Client
    class Manager
      class << self
        attr_accessor :redis_class
      end

      @@client_objects = {}

      def self.find_for_sensor(sensor_name)
        sensor = PulseMeter.sensor(sensor_name)
        if sensor
          client_options = PulseMeter.client(sensor.options[:client])
          Client::Manager.find(client_options)
        end
      end

      def self.find(client)
        raise ArgumentError unless client.kind_of?(PulseMeter::Configuration::Dsl::Client)
        @@client_objects[client.name] ||= create(client)
      end

      def self.create(client)
        if client.remote
          UDP.new(client)
        else
          (self.redis_class ||= Redis).new
        end
      end
    end
  end
end

