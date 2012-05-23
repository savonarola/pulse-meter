require 'pulse-meter/configuration/dsl/client'
require 'pulse-meter/configuration/dsl/sensor'

module PulseMeter
    module Configuration
        class DSL
          attr_reader :clients, :sensors, :remoted, :server, :default_client

          def initialize(&block)
            @remoted = false
            @sensors, @clients = {}, {}

            instance_eval(&block)
          end

          def remote(&block)
            @remoted = true
            instance_eval(&block)
            @remoted = false
          end

          def server(&block)
            if block_given?
              @server = PulseMeter::Configuration::Dsl::Client.new(:server, false, &block)
            else
              @server
            end
          end

          def client(name, params = {}, &block)
            if block_given?
              @clients[name] = PulseMeter::Configuration::Dsl::Client.new(name, @remoted, &block)
              @default_client = @clients[name] if params[:default]
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
              @sensors[name] = PulseMeter::Configuration::Dsl::Sensor.new(name, klass, @remoted, &block)
            else
              @sensors[name]
            end
          end
        end
    end
end
