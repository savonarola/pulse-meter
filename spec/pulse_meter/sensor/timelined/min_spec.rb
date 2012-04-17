require 'spec_helper'

describe PulseMeter::Sensor::Timelined::Min do
  it_should_behave_like "timeline sensor"
  it_should_behave_like "timelined subclass", [1, 2, -1, -1, 5, 0], -1
  it_should_behave_like "timelined subclass", [1], 1
end
