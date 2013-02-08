require 'socket'

module PulseMeter
  module CommandAggregator
    class UDP

      def initialize(host, port)
        @host, @port = host, port
        @buffer = []
        @in_multi = false
      end

      def multi
        @in_multi = true
        yield
      ensure
        @in_multi = false
        send_buffer
      end

      def method_missing(*args)
        @buffer << args
        send_buffer unless @in_multi
      end

      private

      def send_buffer
        data = @buffer.to_json
        sock = UDPSocket.new
        sock.send(data, 0, @host, @port)
        sock.close
      rescue StandardError
        PulseMeter.error "error sending data: #{e}, #{e.backtrace.join("\n")}"
      ensure
        @buffer = []
      end

    end
  end
end

