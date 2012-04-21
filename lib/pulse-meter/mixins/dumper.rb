module PulseMeter
  module Mixins
    module Dumper
      DUMP_REDIS_KEY = "pulse_meter::dump" 

      module InstanceMethods
        def dump!
          ensure_storability!
          serialized_obj = Marshal.dump(self)
          redis.hset(DUMP_REDIS_KEY, self.name, serialized_obj)
        rescue
          raise DumpError, "object cannot be dumped"
        end

        def ensure_storability!
          raise DumpError, "#name attribute must be readable" unless self.respond_to?(:name)
          raise DumpError, "#redis attribute must be available" unless self.respond_to?(:redis) && self.redis
        end

        def cleanup_dump
          redis.del(DUMP_REDIS_KEY)
        end
      end

      module ClassMethods
        def restore(name)
          serialized_obj = PulseMeter.redis.hget(DUMP_REDIS_KEY, name)
          Marshal.load(serialized_obj)
        rescue
          raise RestoreError
        end
      end

      def self.included(base)
        base.send :include, InstanceMethods
        base.send :extend, ClassMethods
      end

    end
  end
end
