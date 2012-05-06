require "redis"
require "pulse-meter/version"
require "pulse-meter/mixins/dumper"
require "pulse-meter/mixins/utils"
require "pulse-meter/server"
require "pulse-meter/sensor"

module PulseMeter
  @@redis = nil

  def self.redis
    @@redis
  end

  def self.redis=(redis)
    @@redis = redis
  end
end
