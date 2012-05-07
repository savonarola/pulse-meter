require 'spec_helper'

describe PulseMeter::Configuration::DSL do
  include_context :configuration

  before { @dsl = PulseMeter.configuration }

  describe "remote client" do
    it "should have remote flag with true value" do
      @dsl.client(:udp).remote.should be_true
    end

    it "should have host parameter" do
      @dsl.client(:udp).host.should == "udp-host"
    end
  end

  describe "remote sensor" do
    it "should have sensor with remote flag" do
      @dsl.sensor(:udp_sensor).remote.should be_true
    end

    it "should have class_name with nil" do
      @dsl.sensor(:udp_sensor).class_name.should be_nil
    end
  end

  describe "#client part" do
    it "should have remote flag with false value" do
      @dsl.client(:first).remote.should be_false
    end

    it "should have client name" do
      @dsl.client(:first).name.should == :first
    end

    it "should have host" do
      @dsl.client(:first).host.should == "localhost"
    end

    it "should have port" do
      @dsl.client(:first).port.should == 1234
    end
  end

  describe "#sensor part" do
    it "should have mapped to client :first" do
      @dsl.sensor(:sensor_name).options[:client].should == :first
    end

    it "should have valid sensor name" do
      @dsl.sensor(:sensor_name).name.should == :sensor_name
    end

    it "should have class_name with valid class" do
      @dsl.sensor(:sensor_name).class_name.should == PulseMeter::Sensor::Timelined::Median
    end
  end
end
