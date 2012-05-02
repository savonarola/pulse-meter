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

      def titleize(str)
        raise ArgumentError unless str.respond_to?(:to_s)
        str.to_s.split(/[\s_]+/).map(&:capitalize).join(' ')
      end

      def camelize(str, first_letter_upper = false)
        raise ArgumentError unless str.respond_to?(:to_s)
        terms = str.to_s.split(/_/)
        first = terms.shift
        (first_letter_upper ? first.capitalize : first.downcase) + terms.map(&:capitalize).join
      end

      def camelize_keys(item)
        case item
        when Array
          item.map{|i| camelize_keys(i)}
        when Hash
          item.each_with_object({}) { |(k, v), h| h[camelize(k)] = camelize_keys(v)}
        else
          item
        end
      end
    end
  end
end
