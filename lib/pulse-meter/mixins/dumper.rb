module PulseMeter
  module Mixins
    # Mixin with dumping utilities
    module Dumper
      # Prefix for Redis keys with dumped sensors' metadata
      DUMP_REDIS_KEY = "pulse_meter:dump"

      module InstanceMethods
        # Serializes object and saves it to Redis
        # @raise [DumpError] if dumping fails for any reason
        def dump!
          ensure_storability!
          serialized_obj = Marshal.dump(self)
          redis.hset(DUMP_REDIS_KEY, self.name, serialized_obj)
        rescue
          raise DumpError, "object cannot be dumped"
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
          Marshal.load(serialized_obj)
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
