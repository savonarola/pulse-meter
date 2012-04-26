require 'securerandom'

module PulseMeter
  module Mixins
    module Utils
      def constantize(const_name)
        return unless const_name.respond_to?(:to_s)
        const_name.to_s.split('::').reduce(Module, :const_get)
      rescue NameError
        nil
      end

      def assert_positive_integer!(options, key, default = nil)
        value = options[key] || default
        raise ArgumentError, "#{key} should be defined" unless value
        raise ArgumentError, "#{key} should be integer" unless value.respond_to?(:to_i)
        raise ArgumentError, "#{key} should be positive" unless value.to_i > 0
        options[key] = value.to_i
      end

      def assert_ranged_float!(options, key, from, to)
        f = options[key]
        raise ArgumentError, "#{key} should be defined" unless f
        raise ArgumentError, "#{key} should be float" unless f.respond_to?(:to_f)
        f = f.to_f
        raise ArgumentError, "#{key} should be between #{from} and #{to}" unless f >= from && f <= to
        options[key] = f
      end

      def uniqid
        SecureRandom.hex(32)
      end
    end
  end
end
