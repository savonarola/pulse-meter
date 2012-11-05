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
  describe "::command_aggregator=" do
    context "when :async passed" do
      it "should set async command_aggregator to be used" do
        PulseMeter.command_aggregator = :async
        PulseMeter.command_aggregator.should be_kind_of(PulseMeter::CommandAggregator::Async)
      end
    end
    context "when :sync passed" do
      it "should set sync command_aggregator to be used" do
        PulseMeter.command_aggregator = :sync
        PulseMeter.command_aggregator.should be_kind_of(PulseMeter::CommandAggregator::Sync)
      end
    end
    context "otherwise" do
      it "should raise ArgumentError" do
        expect{ PulseMeter.command_aggregator = :xxx }.to raise_exception(ArgumentError)
      end
    end
  end

  describe "::command_aggregator" do
    it "should return current command_aggregator" do
      PulseMeter.command_aggregator = :async
      PulseMeter.command_aggregator.should be_kind_of(PulseMeter::CommandAggregator::Async)
      PulseMeter.command_aggregator = :sync
      PulseMeter.command_aggregator.should be_kind_of(PulseMeter::CommandAggregator::Sync)
    end

    it "should always return the same command_aggregator for each type" do
      PulseMeter.command_aggregator = :async
      ca1 = PulseMeter.command_aggregator
      PulseMeter.command_aggregator = :sync
      PulseMeter.command_aggregator = :async
      ca2 = PulseMeter.command_aggregator
      ca1.should == ca2
    end
  end
end
