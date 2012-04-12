require 'spec_helper'

describe PulseMeter::Sensor::Indicator do
  let(:name){ :some_value }
  let(:sensor){ described_class.new(name) }
  let(:redis){ PulseMeter.redis }

  describe "#event" do
    it "should set sensor value to passed value" do
      expect{ sensor.event(10.4) }.to change{ sensor.value }.from(0).to(10.4)
      expect{ sensor.event(15.1) }.to change{ sensor.value }.from(10.4).to(15.1)
    end
  end

  describe "#value_key" do
    it "should be composed of sensor name and :value suffix" do
      sensor.value_key.should == "#{name}:value"
    end
  end

  describe "#value" do
    it "should have initial value 0" do
      sensor.value.should == 0
    end

    it "should store stringified value by value_key" do
      sensor.event(123)
      sensor.value.should == 123
      redis.get(sensor.value_key) == '123'
    end
  end

  describe "#cleanup" do
    it "should remove all sensor data" do
      sensor.annotate("My Indicator")
      sensor.event(123)
      sensor.cleanup
      redis.keys('*').should be_empty
    end
  end

end

