module PulseMeter
  module Utils
    def constantize(const_name)
      return unless const_name.respond_to?(:to_s)
      const_name.to_s.split('::').reduce(Module, :const_get)
    rescue NameError
      nil
    end

    def assert_positive_integer!(options, key)
      value = options[key]
      raise ArgumentError, "#{key} should be integer" unless value.respond_to?(:to_i)
      raise ArgumentError, "#{key} should be positive" unless value.to_i > 0
      options[key] = value.to_i
    end

  end
end
