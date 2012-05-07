require 'spec_helper'

describe PulseMeter::Client::Protocol do
  describe "#pack" do
    it "should pack sensor name and value to needable format" do
      described_class.pack(:sensor_name, 1).should == "sensor_name|1"
    end

    context "when sensor name with space" do
      it "should have valid packed data" do
        described_class.pack("sensor_name ", "1 ").should == "sensor_name|1"
      end
    end
  end

  describe "#unpack" do
    it "should unpack protocol input to sensor's name and value" do
      described_class.unpack("sensor_name|1").should == [:sensor_name, "1"]
    end

    context "when input is empty string" do
      it "should return nil" do
        described_class.unpack("").should be_nil
      end
    end
  end
end
