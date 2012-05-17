module PulseMeter
  module Mixins
    module Dumper
      DUMP_REDIS_KEY = "pulse_meter:dump"

      module InstanceMethods
        def dump!
          ensure_storability!
          serialized_obj = Marshal.dump(self)
          PulseMeter.redis.hset(DUMP_REDIS_KEY, self.name, serialized_obj)
        rescue
          raise DumpError, "object cannot be dumped"
        end

        def ensure_storability!
          raise DumpError, "#name attribute must be readable" unless self.respond_to?(:name)
        end

        def cleanup_dump
          PulseMeter.redis.hdel(DUMP_REDIS_KEY, self.name)
        end
      end

      module ClassMethods
        def restore(name)
          serialized_obj = PulseMeter.redis.hget(DUMP_REDIS_KEY, name)
          Marshal.load(serialized_obj)
        rescue
          raise RestoreError, "cannot restore #{name}"
        end

        def list_names
          PulseMeter.redis.hkeys(DUMP_REDIS_KEY)
        rescue
          raise RestoreError, "cannot get data from redis"
        end

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
