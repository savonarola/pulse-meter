require 'spec_helper'

describe PulseMeter::Sensor::Counter do
  let(:name){ :some_counter }
  let(:sensor){ described_class.new(name) }
  let(:redis){ PulseMeter.redis }

  describe "#event" do
    it "should increment sensor value by passed value" do
      expect{ sensor.event(10) }.to change{ sensor.value }.from(0).to(10)
      expect{ sensor.event(15) }.to change{ sensor.value }.from(10).to(25)
    end

    it "should truncate increment value" do
      expect{ sensor.event(10.4) }.to change{ sensor.value }.from(0).to(10)
      expect{ sensor.event(15.1) }.to change{ sensor.value }.from(10).to(25)
    end
  end

  describe "#value_key" do
    it "should be composed of sensor name and pulse_meter:value: prefix" do
      sensor.value_key.should == "pulse_meter:value:#{name}"
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

  describe "#incr" do
    it "should increment value by 1" do
      expect{ sensor.incr }.to change{ sensor.value }.from(0).to(1)
      expect{ sensor.incr }.to change{ sensor.value }.from(1).to(2)
    end
  end

  describe "#cleanup" do
    it "should remove all sensor data" do
      sensor.annotate("My Counter")
      sensor.event(123)
      sensor.cleanup
      redis.keys('*').should be_empty
    end
  end

end
