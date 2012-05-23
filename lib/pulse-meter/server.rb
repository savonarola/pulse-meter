require 'pulse-meter/client/protocol'
require 'pulse-meter/configuration/dsl'
require 'eventmachine'

module PulseMeter

    class ListenerServer < EventMachine::Connection
      def post_init
       puts "-- someone connected to the echo server!"
      end

       def receive_data(data)
         puts "Recieved: #{data}"
         sensor, value = PulseMeter::Protocol::Client.unpack(data)
         PulseMeter.sensor(sensor.to_sym).event(value)
       rescue Exception => e
         puts "Error: #{e.message}"
       end

       def unbind
         close_connection
       end
    end

    class Server < ::EventMachine::Connection
      def self.start(&block)
        PulseMeter.configuration = PulseMeter::Configuration::DSL.new(&block)

        EM.run do
          EM.open_datagram_socket(PulseMeter.configuration.server.host, PulseMeter.configuration.server.port, ListenerServer)
        end
      end
    end
end
