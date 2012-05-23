require 'pulse-meter/client/protocol'
require 'socket'

module PulseMeter
  module Client
    class Error < Exception; end
    class UDP
      def initialize(client)
        @socket = UDPSocket.new
        @socket.connect(client.host, client.port)
      rescue SocketError => e
        raise Error, e.message
      end

      def send(sensor_name, value)
        packed = Protocol.pack(sensor_name, value)
        @socket.send(packed, flag=0)
      end
    end
  end
end
