class PulseMeter::Listener::Dsl::Sensor
  attr_reader :name, :class_name, :remote, :options

  def initialize(name, class_name, remote, &block)
    @name, @remote, @options, @class_name = name, remote, {}, class_name

    instance_eval(&block)
  end

  def method_missing(name, value)
    if unexpected_params_for_local_client?(name)
      raise "Not valid parameter: #{name} for local client"
    end
    @options[name] = value
  end

 private
  def unexpected_params_for_local_client?(name)
    !@remote && name != :client
  end
end
