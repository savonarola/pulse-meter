require 'spec_helper'

describe PulseMeter::Sensor::Timelined::Indicator do
  it_should_behave_like "timeline sensor"
  it_should_behave_like "timelined subclass", [1, 5, 2], 2
end
