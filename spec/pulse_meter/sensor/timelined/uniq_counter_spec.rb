require 'spec_helper'

describe PulseMeter::Sensor::Timelined::UniqCounter do
  it_should_behave_like "timeline sensor"
  it_should_behave_like "timelined subclass", [:foo, :bar], 2
  it_should_behave_like "timelined subclass", [:foo, :bar, :foo], 2
  data = (1..100).map {rand(200)}
  it_should_behave_like "timelined subclass", data, data.uniq.count
end
