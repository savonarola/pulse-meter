module PulseMeter
  module Utils
    def constantize(const_name)
      return unless const_name.respond_to?(:to_s)
      const_name.to_s.split('::').reduce(Module, :const_get)
    rescue NameError
      nil
    end
  end
end
