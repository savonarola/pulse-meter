require 'spec_helper'

describe PulseMeter::Sensor::Timelined::Percentile do
  it_should_behave_like "timeline sensor", {:p => 0.8}
  it_should_behave_like "timelined subclass", [5, 4, 2, 2, 2, 2, 2, 2, 2, 1], 2, {:p => 0.8}
  it_should_behave_like "timelined subclass", [1], 1, {:p => 0.8}

  let(:init_values) {{:ttl => 1, :raw_data_ttl => 1, :interval => 1, :reduce_delay => 1}}
  let(:name) { :sensor_name }

  it "should raise exception when percentile is not between 0 and 1" do
    expect {described_class.new(name, init_values.merge({:p => -1}))}.to raise_exception(ArgumentError)
    expect {described_class.new(name, init_values.merge({:p => 1.1}))}.to raise_exception(ArgumentError)
    expect {described_class.new(name, init_values.merge({:p => 0.1}))}.not_to raise_exception(ArgumentError)
  end

end
