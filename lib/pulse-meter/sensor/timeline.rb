require 'securerandom'

module PulseMeter
  module Sensor
    class Timeline < Base
      include PulseMeter::Utils

      attr_reader :interval, :ttl, :raw_data_ttl, :reduce_delay

      def initialize(name, options)
        super
        @interval = assert_positive_integer!(options, :interval)
        @ttl = assert_positive_integer!(options, :ttl)
        @raw_data_ttl = assert_positive_integer!(options, :raw_data_ttl)
        @reduce_delay = assert_positive_integer!(options, :reduce_delay)
      end

      def cleanup
        keys = []
        keys << current_buket_id_key
        keys << current_buket_key
        redis.keys(raw_completed_bucket_key('*')).each do |key|
          keys << key
        end
        redis.keys(completed_bucket_key('*')).each do |key|
          keys << key
        end
        multi do
          keys.each{|key| redis.del(key)}
        end
      end

      def event(value)
        multi do
          current_key = current_raw_data_key
          aggregate_event(current_key, value)
          redis.expire(current_key, raw_data_ttl)
        end
      end

      def current_raw_data_key
        raw_data_key(current_interval_id)
      end

      def raw_data_key(id)
        "raw:#{name}:#{id}"
      end

      def data_key(id)
        "data:#{name}:#{id}"
      end

      def current_interval_id
        (Time.now.to_i / interval) * interval
      end

      def aggregate_event(key, value)
        # simple
        redis.set(key, value)
      end

      def summarize(id)
        # simple
        redis.get(raw_data_key(id))  
      end

    end
  end
end

