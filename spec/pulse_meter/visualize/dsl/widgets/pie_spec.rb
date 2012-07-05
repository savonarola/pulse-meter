require 'spec_helper'

describe PulseMeter::Visualize::DSL::Widgets::Pie do
  it_should_behave_like "dsl widget"

  let(:interval){ 100 }
  let(:name) { "some_sensor" }
  let!(:sensor){ PulseMeter::Sensor::Timelined::Max.new(name, :ttl => 1000, :interval => interval) }
  
  let(:widget_name){ "some_widget" }
  let(:w){ described_class.new(widget_name)  }

  describe "#to_data" do
    it "should produce PulseMeter::Visualize::Widgets::Pie class" do
      w.to_data.should be_kind_of(PulseMeter::Visualize::Widgets::Pie)
    end
  end

  describe "#values_label" do
    it "should set values_label" do
      w.values_label "some y-axis legend"
      w.to_data.values_label.should == "some y-axis legend"
    end
  end

  describe "#show_last_point" do
    it "should set show_last_point" do
      w.show_last_point true
      w.to_data.show_last_point.should be_true
    end
  end

end


