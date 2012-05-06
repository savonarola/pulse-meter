require 'pulse-meter/listener/dsl'
require 'eventmachine'

module PulseMeter
    def options=(options)
      @@options = options
    end

    def options
      @@options
    end

    class ProxyConnection
      def initialize(client, request)
         @client, @request = client, request
       end

       def post_init
         EM::enable_proxy(self, @client)
       end

       def connection_completed
         send_data @request
       end

       def proxy_target_unbound
         close_connection
       end

       def unbind
         @client.close_connection_after_writing
       end
    end

    class Server < ::EventMachine::Connection
      def self.start(&block)
        PulseMeter.options = PulseMeter::Listener::DSL.new(&block)

        EM.run do
          EM.open_datagram_socket(PulseMeter.options.server.host, PulseMeter.options.server.port, self)
        end
      end

      def receive_data(data)
        EM.connect("10.0.0.15", 80, ProxyConnection, self, data)
      end
    end
end
