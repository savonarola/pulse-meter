require 'pulse-meter'

module PulseMeter
  class Observer
  extend PulseMeter::Mixins::Utils

    class << self
      # Removes observation from instance method
      # @param klass [Class] class
      # @param method [Symbol] instance method name
      def unobserve_method(klass, method)
        with_observer = method_with_observer(method)
        if klass.method_defined?(with_observer)
          block = unchain_block(method)
          klass.class_eval &block
        end
      end

      # Removes observation from class method
      # @param klass [Class] class
      # @param method [Symbol] class method name
      def unobserve_class_method(klass, method)
        with_observer = method_with_observer(method)
        if klass.respond_to?(with_observer)
          method_owner = metaclass(klass)
          block = unchain_block(method)
          method_owner.instance_eval &block
        end
      end

      # Registeres an observer for instance method
      # @param klass [Class] class
      # @param method [Symbol] instance method
      # @param sensor [Object] notifications receiver
      # @param proc [Proc] proc to be called in context of receiver each time observed method called
      def observe_method(klass, method, sensor, &proc)
        with_observer = method_with_observer(method)
        unless klass.method_defined?(with_observer)
          block = chain_block(method, sensor, &proc)
          klass.class_eval &block
        end
      end

      # Registeres an observer for class method
      # @param klass [Class] class
      # @param method [Symbol] class method
      # @param sensor [Object] notifications receiver
      # @param proc [Proc] proc to be called in context of receiver each time observed method called
      def observe_class_method(klass, method, sensor, &proc)
        with_observer = method_with_observer(method)
        unless klass.respond_to?(with_observer)
          method_owner = metaclass(klass)
          block = chain_block(method, sensor, &proc)
          method_owner.instance_eval &block
        end
      end

      protected

      def define_instrumented_method(method_owner, method, receiver, &handler)
        with_observer = method_with_observer(method)
        without_observer = method_without_observer(method)
        method_owner.send(:define_method, with_observer) do |*args, &block|
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
        me = self

        Proc.new do 
          alias_method(without_observer, method)
          method_owner = self
          me.send(:define_instrumented_method, method_owner, method, receiver, &handler)
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
        "#{method}_with_#{underscore(self).tr('/', '_')}"
      end

      def method_without_observer(method)
        "#{method}_without_#{underscore(self).tr('/', '_')}"
      end
    end
  end
end
