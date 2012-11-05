require 'spec_helper'

describe PulseMeter::CommandAggregator::Sync do
  let(:ca){described_class.instance}
  let(:redis){PulseMeter.redis}

  describe "#multi" do
    it "should accumulate redis command and execute in a bulk" do
      ca.multi do
        ca.set("xxxx", "zzzz").should == "QUEUED"
        ca.set("yyyy", "zzzz").should == "QUEUED"
      end
      redis.get("xxxx").should == "zzzz"
      redis.get("yyyy").should == "zzzz"
    end
  end

  describe "any other redis instance method" do
    it "should be delegated to redis" do
      ca.set("xxxx", "zzzz")
      redis.get("xxxx").should == "zzzz"
    end
  end
end

