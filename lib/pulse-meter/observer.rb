require 'pulse-meter'

module PulseMeter
  class Observer
    class << self
      # Removes observation from instance method
      # @param klass [Class] class
      # @param method [Symbol] instance method name
      def unobserve_method(klass, method)
        with_observer = method_with_observer(method)
        without_observer = method_without_observer(method)

        return unless klass.method_defined? with_observer
        klass.class_eval do
          alias_method method, without_observer
          remove_method with_observer
          remove_method without_observer
        end
      end

      # Removes observation from class method
      # @param klass [Class] class
      # @param method [Symbol] class method name
      def unobserve_class_method(klass, method)
        with_observer = method_with_observer(method)
        without_observer = method_without_observer(method)

        return unless klass.respond_to? with_observer
        metaclass(klass).instance_eval do
          alias_method method, without_observer
          remove_method with_observer
          remove_method without_observer
        end
      end

      # Registeres an observer for instance method
      # @param klass [Class] class
      # @param method [Symbol] instance method
      # @param sensor [Object] notifications receiver
      # @param proc [Proc] proc to be called in context of receiver each time observed method called
      def observe_method(klass, method, sensor, &proc)
        with_observer = method_with_observer(method)
        without_observer = method_without_observer(method)

        return if klass.method_defined? with_observer
            
        klass.class_eval do
          alias_method without_observer, method
          define_method with_observer do |*args|
            result = nil
            begin
              sensor.instance_exec *args, &proc
            rescue Exception
            ensure
              result = self.send without_observer, *args
            end
            result
          end
          alias_method method, with_observer
        end
      end

      # Registeres an observer for class method
      # @param klass [Class] class
      # @param method [Symbol] class method
      # @param sensor [Object] notifications receiver
      # @param proc [Proc] proc to be called in context of receiver each time observed method called
      def observe_class_method(klass, method, sensor, &proc)
        with_observer = method_with_observer(method)
        without_observer = method_without_observer(method)

        return if klass.respond_to? with_observer

        metaclass(klass).instance_eval do
          alias_method without_observer, method
          define_method with_observer do |*args|
            result = nil
            begin
              sensor.instance_exec *args, &proc
            rescue Exception
            ensure
              result = self.send without_observer, *args
            end
            result
          end
          alias_method method, with_observer
        end
      end

      private

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
