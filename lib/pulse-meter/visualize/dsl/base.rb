module PulseMeter
  module Visualize
    module DSL
      class DArray < Array; end 
      class BadDataClass < PulseMeter::Error; end
      class Base
        include PulseMeter::Mixins::Utils

        def initialize
          @opts = {}
        end

        def process_args(args)
          args.each_pair do |k, v|
            send(k, v)
          end
        end

        class << self
          
          def deprecated_setter(name)
            define_method(name) do |*args|
              STDERR.puts "DEPRECATION: #{name} DSL helper does not take any effect anymore."
            end
          end
          
          def setter(name, &block)
            define_method(name) do |val|
              block.call(val) if block
              @opts[name] = val
            end
          end

          def bool_setter(name)
            define_method(name) do |val|
              @opts[name] = !!val
            end
          end

          def string_setter(name, &block)
            define_method(name) do |val|
              val = val.to_s
              block.call(val) if block
              @opts[name] = val
            end
          end

          def int_setter(name, &block)
            define_method(name) do |val|
              val = val.to_i
              block.call(val) if block
              @opts[name] = val
            end
          end

          def hash_extender(name, &block)
            define_method(name) do |val|
              @opts[name] ||= {}
              @opts[name].merge!(val)
            end
          end

          def array_extender(name, &block)
            define_method(name) do |val|
              @opts[name] ||=[]
              block.call(val) if block
              @opts[name] << val
            end
          end
          
          def dsl_setter(name, klass)
            define_method(name) do |*args, &block|
              @opts[name] = create_dsl_obj(args, klass, block)
            end
          end

          def dsl_array_extender(collection_name, name, klass)
            define_method(name) do |*args, &block|
              @opts[collection_name] ||= DArray.new
              @opts[collection_name] << create_dsl_obj(args, klass, block)
            end
          end

          def create_dsl_obj(args, klass, block)
            params, options = extract_params(args)
            dsl_obj = klass.new(params)
            dsl_obj.process_args(options)
            block.call(dsl_obj) if block
            dsl_obj
          end

          def extract_params(args)
            opts = if args.last.is_a?(Hash)
              args.pop
            else
              {}
            end
            [args, opts]
          end

          def data_class
            @data_class || PulseMeter::Visualize::Base
          end

          def data_class=(klass)
            raise BadDataClass unless klass.is_a?(Class) && klass <= PulseMeter::Visualize::Base
            @data_class = klass
          end

        end

        def to_data
          klass = self.class.data_class
          args = @opts.each_with_object({}) do |(k, v), acc|
            acc[k] = case v
              when PulseMeter::Visualize::DSL::Base
                v.to_data
              when DArray
                v.map(&:to_data)
              else
                v
            end
          end
          klass.new(args)
        end

      end
    end
  end
end

