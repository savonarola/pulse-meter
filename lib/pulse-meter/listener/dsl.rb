require 'pulse-meter/listener/dsl/client'
require 'pulse-meter/listener/dsl/sensor'

module PulseMeter
    module Listener
        class DSL
          attr_reader :clients, :sensors, :remoted

          def initialize(&block)
            @remoted = false
            @sensors = {}
            @clients = {}

            instance_eval(&block)
          end

          def remote(&block)
            @remoted = true
            instance_eval(&block)
            @remoted = false
          end

          def client(name, &block)
            if block_given?
              @clients[name] = PulseMeter::Listener::Dsl::Client.new(name, @remoted, &block)
            else
              @clients[name]
            end
          end

          def sensor(param, &block)
            name, klass = if param.kind_of?(Hash)
              [param.keys.first, param.values.first]
            else
              [param, nil]
            end

            if block_given?
              @sensors[name] = PulseMeter::Listener::Dsl::Sensor.new(name, klass, @remoted, &block)
            else
              @sensors[name]
            end
          end
        end
    end
end
