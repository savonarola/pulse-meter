require 'spec_helper'

describe PulseMeter::Visualize::DSL::Widgets::Gauge do
  it_should_behave_like "dsl widget"

  let(:interval){ 100 }
  let(:name) { "some_sensor" }
  let!(:sensor){ PulseMeter::Sensor::Timelined::Max.new(name, :ttl => 1000, :interval => interval) }
  
  let(:widget_name){ "some_widget" }
  let(:w){ described_class.new(widget_name)  }

  describe "#to_data" do
    it "should produce PulseMeter::Visualize::Widgets::Gauge class" do
      w.to_data.should be_kind_of(PulseMeter::Visualize::Widgets::Gauge)
    end
  end

end



