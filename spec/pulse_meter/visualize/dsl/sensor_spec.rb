require 'spec_helper'

describe PulseMeter::Visualize::DSL::Sensor do
  let(:interval){ 100 }
  let(:name) { "some_sensor" }
  let!(:sensor){ PulseMeter::Sensor::Timelined::Max.new(name, :ttl => 1000, :interval => interval) }

  describe '.new' do
    it "should save passed name and create Visualize::Sensor with it" do
      described_class.new(:foo).to_sensor.timeline(10)[:name].to_s.should == name
    end
  end


end

