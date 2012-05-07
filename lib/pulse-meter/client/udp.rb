require 'pulse-meter/client/protocol'

module PulseMeter
  module Client
    class UDP
      def new(client)
      end

      def send(sensor_name, value)
        socket.write(Protocol.pack(sensor_name, value))
      end

      # usage:
      # sensor_name, value = udp_client.receive
      def receive
        Protocol.unpack(socket.recv(1024))
      end
    end
  end
end
