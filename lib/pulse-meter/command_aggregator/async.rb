require 'singleton'
require 'thread'

module PulseMeter
  module CommandAggregator
    class Async
      include Singleton

      MAX_QUEUE_LENGTH = 10_000

      attr_reader :max_queue_length

      def initialize
        @max_queue_length = MAX_QUEUE_LENGTH
        @queue = Queue.new
        @buffer = []
        @in_multi = false
        @consumer_thread = run_consumer
      end

      def multi
        @in_multi = true
        yield
      ensure
        @in_multi = false
        send_buffer_to_queue
      end

      def method_missing(*args)
        @buffer << args
        send_buffer_to_queue unless @in_multi
      end

      def wait_for_pending_events(max_seconds = 1)
        left_to_wait = max_seconds.to_f
        sleep_step = 0.01
        while has_pending_events? && left_to_wait > 0
          left_to_wait -= sleep_step
          sleep(sleep_step)
        end
      end

      private

      def has_pending_events?
        !@queue.empty?
      end

      def send_buffer_to_queue
        if @queue.size < @max_queue_length
          @queue << @buffer
        end
        @buffer = []
      end

      def redis
        PulseMeter.redis
      end

      def consume_commands
        # redis and @queue are threadsafe
        while commands = @queue.pop
          begin
            redis.multi do 
              commands.each do |command|
                redis.send(*command)
              end
            end
          rescue StandardError => e
            STDERR.puts "error in consumer_thread: #{e}, #{e.backtrace.join("\n")}"
          end
        end
      end

      def run_consumer
        Thread.new do
          consume_commands
        end
      end
    end
  end
end
