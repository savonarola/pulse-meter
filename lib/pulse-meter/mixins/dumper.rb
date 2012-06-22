require 'yaml'

module PulseMeter
  module Mixins
    # Mixin with dumping utilities
    module Dumper
      # Prefix for Redis keys with dumped sensors' metadata
      DUMP_REDIS_KEY = "pulse_meter:dump"

      module InstanceMethods
        # Serializes object and saves it to Redis
        # @param safe [Boolean] forbids dump if sensor has already been dumped
        # @raise [DumpConflictError] if object class conflicts with stored object class
        # @raise [DumpError] if dumping fails for any reason
        def dump!(safe = true)
          ensure_storability!
          serialized_obj = to_yaml
          if safe
            unless redis.hsetnx(DUMP_REDIS_KEY, name, serialized_obj)
              stored = self.class.restore(name)
              unless stored.class == self.class
                raise DumpConflictError, "Attempt to create sensor #{name} of class #{self.class} but it already has class #{stored.class}"
              end
            end
          else
            redis.hset(DUMP_REDIS_KEY, name, serialized_obj)
          end
        rescue DumpError, RestoreError => exc
          raise exc
        rescue StandardError => exc
          raise DumpError, "object cannot be dumped: #{exc}"
        end

        # Ensures that object is dumpable
        # @raise [DumpError] if object cannot be dumped
        def ensure_storability!
          raise DumpError, "#name attribute must be readable" unless self.respond_to?(:name)
          raise DumpError, "#redis attribute must be available" unless self.respond_to?(:redis) && self.redis
        end
        
        # Cleans up object dump in Redis 
        def cleanup_dump
          redis.hdel(DUMP_REDIS_KEY, self.name)
        end
      end

      module ClassMethods
        # Restores object from Redis
        # @param name [String] object name
        # @return [Object]
        # @raise [RestoreError] if object cannot be restored for any reason
        def restore(name)
          serialized_obj = PulseMeter.redis.hget(DUMP_REDIS_KEY, name)
          YAML::load(serialized_obj)
        rescue
          raise RestoreError, "cannot restore #{name}"
        end

        # Lists all dumped objects' names
        # @return [Array<String>]
        # @raise [RestoreError] if list cannot be retrieved for any reason
        def list_names
          PulseMeter.redis.hkeys(DUMP_REDIS_KEY)
        rescue
          raise RestoreError, "cannot get data from redis"
        end

        # Safely restores all dumped objects
        # @return [Array<Object>]
        def list_objects
          list_names.each_with_object([]) do |name, objects|
            begin
              objects << restore(name)
            rescue
            end
          end
        end
      end

      def self.included(base)
        base.send :include, InstanceMethods
        base.send :extend, ClassMethods
      end

    end
  end
end
