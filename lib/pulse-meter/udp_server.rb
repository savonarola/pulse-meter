require 'socket'
require 'timeout'

module PulseMeter
  class UDPServer
    MAX_PACKET = 1024
  
    def initialize(host, port)
      @socket = UDPSocket.new
      @socket.do_not_reverse_lookup = true
      @socket.bind(host, port)
    end

    def start(max_packets = nil)
      while true do
        if max_packets
          break if max_packets <= 0
          max_packets -= 1
        end
        process_packet
      end
    end

    private

    def process_packet
      raw_data, _ = @socket.recvfrom(MAX_PACKET)
      data = parse_data(raw_data)
      PulseMeter.redis.multi do
        data.each do |command|
          PulseMeter.redis.send(*command)
        end
      end
    rescue StandardError => e
      PulseMeter.error "Error processing packet: #{e}"
    end

    def parse_data(data)
      JSON.parse(data)
    rescue
      PulseMeter.error "Bad redis data: #{data.inspect}"
      []
    end
  end
end
