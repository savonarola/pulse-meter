require 'pulse-meter'

module PulseMeter
  class Observer
    class << self
      # Removes observation from instance method
      # @param klass [Class] class
      # @param method [Symbol] instance method name
      def unobserve_method(klass, method)
        if klass.method_defined?(method_with_observer(method))
          klass.class_eval(&unchain_block(method))
        end
      end

      # Removes observation from class method
      # @param klass [Class] class
      # @param method [Symbol] class method name
      def unobserve_class_method(klass, method)
        if klass.respond_to?(method_with_observer(method))
          metaclass(klass).instance_eval(&unchain_block(method))
        end
      end

      # Registeres an observer for instance method
      # @param klass [Class] class
      # @param method [Symbol] instance method
      # @param sensor [Object] notifications receiver
      # @param proc [Proc] proc to be called in context of receiver each time observed method called
      def observe_method(klass, method, sensor, &proc)
        unless klass.method_defined?(method_with_observer(method))
          klass.class_eval(&chain_block(method, sensor, &proc))
        end
      end

      # Registeres an observer for class method
      # @param klass [Class] class
      # @param method [Symbol] class method
      # @param sensor [Object] notifications receiver
      # @param proc [Proc] proc to be called in context of receiver each time observed method called
      def observe_class_method(klass, method, sensor, &proc)
        unless klass.respond_to?(method_with_observer(method))
          metaclass(klass).instance_eval(&chain_block(method, sensor, &proc))
        end
      end

      private

      def unchain_block(method)
        with_observer = method_with_observer(method)
        without_observer = method_without_observer(method)

        Proc.new do
          alias_method(method, without_observer)
          remove_method(with_observer)
          remove_method(without_observer)
        end
      end

      def chain_block(method, receiver, &handler)
        with_observer = method_with_observer(method)
        without_observer = method_without_observer(method)

        Proc.new do 
          alias_method(without_observer, method)
          define_method(with_observer) do |*args, &block|
            start_time = Time.now
            begin
              self.send(without_observer, *args, &block)
            ensure
              begin
                delta = ((Time.now - start_time) * 1000).to_i
                receiver.instance_exec(delta, *args, &handler)
              rescue StandardError
              end
            end
          end
          alias_method(method, with_observer)
        end
      end

      def metaclass(klass)
        klass.class_eval do
          class << self
            self
          end
        end
      end

      def method_with_observer(method)
        "#{method}_with_observer"
      end

      def method_without_observer(method)
        "#{method}_without_observer"
      end
    end
  end
end
