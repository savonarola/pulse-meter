require 'socket'
require 'fcntl'

module PulseMeter
  module CommandAggregator
    class UDP

      def initialize(servers = [])
        raise ArgumentError, "No servers specified" if servers.empty?
        @servers = servers
        @buffer = []
        @in_multi = false
        @sock = UDPSocket.new
        @sock.fcntl(Fcntl::F_SETFL, @sock.fcntl(Fcntl::F_GETFL) | Fcntl::O_NONBLOCK)
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
        @sock.send(data, 0, *@servers.sample)
      rescue StandardError
        PulseMeter.error "error sending data: #{e}, #{e.backtrace.join("\n")}"
      ensure
        @buffer = []
      end

    end
  end
end

