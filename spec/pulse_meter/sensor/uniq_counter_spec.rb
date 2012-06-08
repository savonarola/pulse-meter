require 'spec_helper'

describe PulseMeter::Sensor::UniqCounter do
  let(:name){ :some_counter }
  let(:sensor){ described_class.new(name) }
  let(:redis){ PulseMeter.redis }

  describe "#event" do
    it "should count unique values" do
      expect{ sensor.event(:first) }.to change{sensor.value}.to(1)
      expect{ sensor.event(:first) }.not_to change{sensor.value}
      expect{ sensor.event(:second) }.to change{sensor.value}.from(1).to(2)
    end
  end

  describe "#value" do
    it "should have initial value 0" do
      sensor.value.should == 0
    end

    it "should return count of unique values" do
      data = (1..100).map {rand(200)}
      data.each {|e| sensor.event(e)}
      sensor.value.should == data.uniq.count
    end
  end

end
