require 'spec_helper'

describe PulseMeter::Sensor::HashedCounter do
  let(:name){ :some_counter }
  let(:sensor){ described_class.new(name) }
  let(:redis){ PulseMeter.redis }

  describe "#event" do
    it "should increment sensor value by passed value" do
      expect{ sensor.event({"foo" => 10}) }.to change{ sensor.value["foo"] }.from(0).to(10)
      expect{ sensor.event({"foo" => 15}) }.to change{ sensor.value["foo"] }.from(10).to(25)
    end

    it "should truncate increment value" do
      expect{ sensor.event({"foo" => 10.4}) }.to change{ sensor.value["foo"] }.from(0).to(10)
      expect{ sensor.event({"foo" => 15.1}) }.to change{ sensor.value["foo"] }.from(10).to(25)
    end

    it "should increment total value" do
      expect{ sensor.event({"foo" => 1, "bar" => 2}) }.to change{sensor.value["total"]}.from(0).to(3)
    end
  end

  describe "#value" do
    it "should have initial value 0" do
      sensor.value["foo"].should == 0
    end

    it "should store redis hash by value_key" do
      sensor.event({"foo" => 1})
      sensor.value.should == {"foo" => 1, "total" => 1}
      redis.hgetall(sensor.value_key).should == {"foo" => "1", "total" => "1"}
    end
  end

  describe "#incr" do
    it "should increment key value by 1" do
      expect{ sensor.incr("foo") }.to change{ sensor.value["foo"] }.from(0).to(1)
      expect{ sensor.incr("foo") }.to change{ sensor.value["foo"] }.from(1).to(2)
    end
  end

end
