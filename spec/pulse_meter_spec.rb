require 'spec_helper'

describe PulseMeter do
  describe "::redis=" do
    it "should store redis" do
      PulseMeter.redis = 'redis'
      PulseMeter.redis.should == 'redis'
    end
  end
  describe "::redis" do
    it "should retrieve redis" do
      PulseMeter.redis = 'redis'
      PulseMeter.redis.should == 'redis'
    end
  end
end
