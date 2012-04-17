require 'spec_helper'

describe PulseMeter::Sensor::Timelined::Max do
  it_should_behave_like "timeline sensor"
  it_should_behave_like "timelined subclass", [1, 2, -1, -1, 5, 0], 5
  it_should_behave_like "timelined subclass", [1], 1
end
