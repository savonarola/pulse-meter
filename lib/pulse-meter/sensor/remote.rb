require 'socket'
require 'json'

module PulseMeter
  module Sensor

    # Remote sensor, i.e. a simple UDP proxy for sending data without
    # taking in account backend performance issues
    class Remote < Base

      DEFAULT_PORT = 27182
      DEFAULT_HOST = 'localhost'

      # @!attribute [r] name
      #   @return [String] sensor name
      attr_reader :name

      # Initializes sensor and creates UDP socket
      # @param name [String] sensor name
      # @option options [Symbol] :host host for remote pulse-meter daemon
      # @option options [Symbol] :port port for remote pulse-meter daemon
      # @raise [BadSensorName] if sensor name is malformed
      # @raise [ConnectionError] if invalid host or port are provided
      def initialize(name, options={})
        @name = name.to_s
        raise BadSensorName, @name unless @name =~ /\A\w+\z/
        host = options[:host].to_s || DEFAULT_HOST
        port = options[:port].to_i || DEFAULT_PORT
        @socket = UDPSocket.new
        socket_action do
          @socket.connect(host, port)
        end
      end

      # Send value to remote sensor
      # @param value value for remote sensor
      # @raise [ConnectionError] if remote daemon is not available
      # @raise [MessageTooLarge] if event data is too large to be serialized into a UDP datagram
      def event(value)
        events(name => value)
      end

      # Send values to multiple remote sensors
      # @param event_data hash with remote sensor names as keys end event value for each value as sensor
      def events(event_data)
        raise ArgumentError unless event_data.is_a?(Hash)
        socket_action do
          @socket.send(event_data.to_json, 0)
        end
      end

      private

      def socket_action
        yield
      rescue SocketError, Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL => exc
        raise PulseMeter::Remote::ConnectionError, exc.to_s
      rescue Errno::EMSGSIZE => exc
        raise PulseMeter::Remote::MessageTooLarge, exc.to_s
      end
    end
  end
end