require 'pulse-meter'

module PulseMeter
  class Observer::Extended < ::PulseMeter::Observer
    class << self
      protected

      def define_instrumented_method(method_owner, method, receiver, &handler)
        with_observer = method_with_observer(method)
        without_observer = method_without_observer(method)
        method_owner.send(:define_method, with_observer) do |*args, &block|
          start_time = Time.now
          begin
            result = self.send(without_observer, *args, &block)
          ensure
            begin
              delta = ((Time.now - start_time) * 1000).to_i
              observe_parameters = {
                self: self,
                delta: delta,
                result: result,
                args: args,
                exception: $!
              }
              receiver.instance_exec(observe_parameters, &handler)
            rescue StandardError
            end
          end
        end
      end

    end
  end
end