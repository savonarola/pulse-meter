require 'spec_helper'

describe PulseMeter::CommandAggregator::Async do
  let(:ca){PulseMeter.command_aggregator}
  let(:redis){PulseMeter.redis}

  describe "#multi" do
    it "should accumulate redis command and execute in a bulk" do
      ca.multi do
        ca.set("xxxx", "zzzz")
        ca.set("yyyy", "zzzz")
        sleep 0.1
        redis.get("xxxx").should be_nil
        redis.get("yyyy").should be_nil
      end
      ca.wait_for_pending_events
      redis.get("xxxx").should == "zzzz"
      redis.get("yyyy").should == "zzzz"
    end
  end

  describe "any other redis instance method" do
    it "should be delegated to redis" do
      ca.set("xxxx", "zzzz")
      ca.wait_for_pending_events
      redis.get("xxxx").should == "zzzz"
    end

    it "should be aggregated if queue is not overflooded" do
      redis.set("x", 0)
      ca.max_queue_length.times{ ca.incr("x") }
      ca.wait_for_pending_events
      redis.get("x").to_i.should == ca.max_queue_length
    end

    it "should not be aggregated if queue is overflooded" do
      redis.set("x", 0)
      (ca.max_queue_length * 2).times{ ca.incr("x") }
      ca.wait_for_pending_events
      redis.get("x").to_i.should < 2 * ca.max_queue_length
    end
  end

  describe "#wait_for_pending_events" do
    it "should pause execution until aggregator thread sends all commands ro redis" do
      ca.set("xxxx", "zzzz")
      redis.get("xxxx").should be_nil
      ca.wait_for_pending_events
      redis.get("xxxx").should == "zzzz"
    end
  end

end
