require 'spec_helper'

describe PulseMeter::Sensor::Timelined::Median do
  it_should_behave_like "timeline sensor"
  it_should_behave_like "timelined subclass", [5, 4, 3, 2, 1], 3
  it_should_behave_like "timelined subclass", [1], 1
end
