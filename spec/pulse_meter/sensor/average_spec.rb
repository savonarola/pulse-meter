require 'spec_helper'

describe PulseMeter::Sensor::Average do
  let(:name){ :avg }
  let(:ttl){ 100 }
  let(:raw_data_ttl){ 10 }
  let(:interval){ 5 }
  let(:reduce_delay){ 3 }
  let(:init_values){ {:ttl => ttl, :raw_data_ttl => raw_data_ttl, :interval => interval, :reduce_delay => reduce_delay} }
  let(:sensor){ described_class.new(name, init_values) }
  let(:redis){ PulseMeter.redis }

  it_should_behave_like "timeline sensor"

  it "should calculate average value" do
    sensor.event(1)
    sensor.event(2)
    data = sensor.timeline(1 + interval).first
    data.value.should == 1.5
  end

end
