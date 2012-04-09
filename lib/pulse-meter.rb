require "pulse-meter/version"
require "pulse-meter/sensor"
require "pulse-meter/utils"

module PulseMeter
  @@redis = nil

  def self.redis
    @@redis 
  end

  def self.redis=(redis)
    @@redis = redis
  end
end
