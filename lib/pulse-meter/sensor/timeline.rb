require 'securerandom'

module PulseMeter
  module Sensor
    class Timeline < Base
      include PulseMeter::Utils

      attr_reader :interval, :ttl, :raw_data_ttl

      def initialize(name, options)
        super
        @interval = assert_positive_integer!(options, :interval)
        @ttl = assert_positive_integer!(options, :ttl)
        @raw_data_ttl = assert_positive_integer!(options, :raw_data_ttl)
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
        rotate
        aggregate_event(value, current_buket_key)
      end

      def current_buket_key
        "#{name}:current_buket"
      end


      protected
      
      @queue = :pulse_meter

      def current_buket_id_key
        "#{name}:current_buket_id"
      end

      def raw_completed_bucket_key(id)
        "#{name}:raw:#{id}"
      end

      def completed_bucket_key(id)
        "#{name}:comp:#{id}"
      end

      def current_buket_id
        (((Time.now.to_i / interval) + 1) * interval).to_s
      end

      def rotate
        old_id = redis.get(current_buket_id_key)
        current_id = current_buket_id
        if old_id && old_id.to_i < current_id
          raw_data_key = raw_completed_bucket_key(old_id)
          multi do
            redis.set(current_buket_id_key, current_id)
            redis.renamenx(current_buket_key, raw_data_key)
            redis.expire(raw_data_key, raw_data_ttl)
          end
          Resque.enqueue(self.class, self, old_id)
        end
      end

      def self.perform(sensor, bucket_id)
        redis = PulseMeter.redis
        summarize_from = sensor.claim_data_for_summarize(bucket_id)
        if summarize_from
          summarized_value = sensor.summarize(summarize_from)
          summarize_to = completed_bucket_key(bucket_id)
          multi do
            redis.del(tmp_key)
            redis.set(summarize_to, summarized_value)
            redis.expire(summarize_to, ttl)
          end
        end
      end

      def claim_data_for_summarize(bucket_id)
        summarize_from = raw_completed_bucket_key(bucket_id)
        tmp_key = sensor.temp_key
        already_summarized = begin
          redis.rename(summarize_from, tmp_key)
          redis.expire(tmp_key, raw_data_ttl)
          tmp_key
        rescue RuntimeError => e
          if e.to_s =~ /no such key/
            nil
          else
            raise e
          end
        end
      end

      def temp_key
        "#{name}:summarize:#{SecureRandom.hex(32)}"
      end

      def aggregate_event(value, key)
        # simple
        redis.set(key, value)
      end

      def summarize(key)
        # simple
        redis.get(key)  
      end

    end
  end
end

