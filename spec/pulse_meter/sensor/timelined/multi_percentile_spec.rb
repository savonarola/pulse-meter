require 'spec_helper'

describe PulseMeter::Sensor::Timelined::MultiPercentile do
  it_should_behave_like "timeline sensor", {:p => [0.8]}
  it_should_behave_like "timelined subclass", [5, 4, 2, 2, 2, 2, 2, 2, 2, 1], {0.8 => 2, 0.5 => 2}.to_json, {:p => [0.8, 0.5]}
  it_should_behave_like "timelined subclass", [1], {0.8 => 1}.to_json, {:p => [0.8]}
  
  let(:init_values) {{:ttl => 1, :raw_data_ttl => 1, :interval => 1, :reduce_delay => 1}}
  let(:name) {"percentile"}

  it "should raise exception when extra parameter is not array of percentiles" do
    expect {described_class.new(name, init_values.merge({:p => :bad}))}.to raise_exception(ArgumentError) 
  end

  it "should raise exception when one of percentiles is not between 0 and 1" do
    expect {described_class.new(name, init_values.merge({:p => [0.5, -1]}))}.to raise_exception(ArgumentError) 
    expect {described_class.new(name, init_values.merge({:p => [0.5, 1.1]}))}.to raise_exception(ArgumentError) 
    expect {described_class.new(name, init_values.merge({:p => [0.5, 0.1]}))}.not_to raise_exception(ArgumentError) 
  end

end
