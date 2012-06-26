require 'spec_helper'

describe PulseMeter::Sensor::HashedIndicator do
  let(:name){ :some_counter }
  let(:sensor){ described_class.new(name) }
  let(:redis){ PulseMeter.redis }

  describe "#event" do
    it "should set sensor value to passed value" do
      expect{ sensor.event("foo" => 10.4) }.to change{ sensor.value["foo"] }.from(0).to(10.4)
      expect{ sensor.event("foo" => 15.1) }.to change{ sensor.value["foo"] }.from(10.4).to(15.1)
    end

    it "should take multiple events" do
      data = {"foo" => 1.1, "boo" => 2.2}
      sensor.event(data)
      sensor.value.should == data
    end
  end

  describe "#value_key" do
    it "should be composed of sensor name and pulse_meter:value: prefix" do
      sensor.value_key.should == "pulse_meter:value:#{name}"
    end
  end

  describe "#value" do
    it "should have initial value 0" do
      sensor.value["foo"].should == 0
    end

    it "should store redis hash by value_key" do
      sensor.event({"foo" => 1})
      sensor.value.should == {"foo" => 1}
      redis.hgetall(sensor.value_key).should == {"foo" => "1.0"}
    end
  end

end
