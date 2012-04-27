require 'spec_helper'

describe PulseMeter::Visualize::DSL::Sensor do
  let(:interval){ 100 }
  let(:name) { "some_sensor" }
  let!(:sensor){ PulseMeter::Sensor::Timelined::Max.new(name, :ttl => 1000, :interval => interval) }

  describe '.new' do
    it "should save passed name and create Visualize::Sensor with it" do
      described_class.new(name).to_sensor.timeline(10)[:name].to_s.should == name
    end
  end

  describe '#process_args' do
    it "should pass args transparently to Visualize::Sensor" do
      s = described_class.new(name)
      s.process_args :color => :red
      s.to_sensor.timeline(10)[:color].to_s.should == 'red'
    end
  end

  describe '#to_sensor' do
    # actually tested above
    it "should convert dsl data to sensor" do
      described_class.new(name).to_sensor.should be_kind_of(PulseMeter::Visualize::Sensor)
    end
  end

end

