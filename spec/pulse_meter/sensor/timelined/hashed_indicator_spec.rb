require 'spec_helper'

describe PulseMeter::Sensor::Timelined::HashedIndicator do
  it_should_behave_like "timeline sensor", {}, {:foo => 1}
  it_should_behave_like "timelined subclass", [{:foo => 1}, {:foo => 2}], {:foo => 2}.to_json
  it_should_behave_like "timelined subclass", [{:foo => 1}, {:foo => :bad_value}], {:foo => 1}.to_json
  it_should_behave_like "timelined subclass", [{:foo => 1}, {:boo => 2}], {:foo => 1, :boo => 2}.to_json
end
