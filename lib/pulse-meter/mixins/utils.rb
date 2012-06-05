require 'securerandom'

module PulseMeter
  module Mixins
    # Mixin with various useful functions 
    module Utils
      # Tries to find a class with the name specified in the argument string
      # @param const_name [String] class name
      # @return [Class] if given class definde
      # @return [NilClass] if given class is not defined
      def constantize(const_name)
        return unless const_name.respond_to?(:to_s)
        const_name.to_s.split('::').reduce(Module, :const_get)
      rescue NameError
        nil
      end

      # Ensures that hash value specified by key can be converted to positive integer.
      # In case it can makes in-place conversion and returns the value.
      # @param options [Hash] hash to be looked at
      # @param key [Object] hash key
      # @param default [Object] default value to be returned
      # @raise [ArgumentError] unless value is positive integer
      # @return [Fixnum]
      def assert_positive_integer!(options, key, default = nil)
        value = options[key] || default
        raise ArgumentError, "#{key} should be defined" unless value
        raise ArgumentError, "#{key} should be integer" unless value.respond_to?(:to_i)
        raise ArgumentError, "#{key} should be positive" unless value.to_i > 0
        options[key] = value.to_i
      end

      # Ensures that hash value specified by key is can be converted to float
      # and it is within given range.
      # In case it can makes in-place conversion and returns the value.
      # @param options [Hash] hash to be looked at
      # @param key [Object] hash key
      # @param from [Float] lower bound
      # @param to [Float] upper bound
      # @raise [ArgumentError] unless value is float within given range
      # @return [Float]
      def assert_ranged_float!(options, key, from, to)
        f = options[key]
        raise ArgumentError, "#{key} should be defined" unless f
        raise ArgumentError, "#{key} should be float" unless f.respond_to?(:to_f)
        f = f.to_f
        raise ArgumentError, "#{key} should be between #{from} and #{to}" unless f >= from && f <= to
        options[key] = f
      end

      # Generates uniq random string
      # @return [String]
      def uniqid
        SecureRandom.hex(32)
      end

      # Capitalizes the first letter of each word in string
      # @param str [String]
      # @return [String]
      # @raise [ArgumentError] unless passed value responds to to_s
      def titleize(str)
        raise ArgumentError unless str.respond_to?(:to_s)
        str.to_s.split(/[\s_]+/).map(&:capitalize).join(' ')
      end

      # Converts string from snake_case to CamelCase
      # @param str [String] string to be camelized
      # @param first_letter_upper [TrueClass, FalseClass] says if the first letter must be uppercased
      # @return [String]
      # @raise [ArgumentError] unless passed value responds to to_s
      def camelize(str, first_letter_upper = false)
        raise ArgumentError unless str.respond_to?(:to_s)
        terms = str.to_s.split(/_/)
        first = terms.shift
        (first_letter_upper ? first.capitalize : first.downcase) + terms.map(&:capitalize).join
      end

      # Symbolizes hash keys
      def symbolize_keys(h)
        h.each_with_object({}) do |(k, v), acc|
          new_k = if k.respond_to?(:to_sym)
            k.to_sym
          else
            k
          end
          acc[new_k] = v
        end
      end

      # Deeply capitalizes Array values or Hash keys
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
