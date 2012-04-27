require 'spec_helper'

describe PulseMeter::Visualize::DSL::Widget do
  let(:interval){ 100 }
  let(:name) { "some_sensor" }
  let(:type) { :some_type }
  let!(:sensor){ PulseMeter::Sensor::Timelined::Max.new(name, :ttl => 1000, :interval => interval) }
  let(:w){ described_class.new(type, name)  }

  describe '.new' do
    it "should raise exception if name arg is empty" do
      lambda{ described_class.new(:chart, '') }.should raise_exception(PulseMeter::Visualize::DSL::BadWidgetName)
    end

    it "should raise exception if type arg is empty" do
      lambda{ described_class.new('', name) }.should raise_exception(PulseMeter::Visualize::DSL::BadWidgetType)
    end

    it "should set default values for name, title, width paprams" do
      wid = w.to_widget
      wid.name.should == name
      wid.type.should == :some_type
      wid.width.should == PulseMeter::Visualize::DSL::Widget::DEFAULT_WIDTH
      wid.title.should == "Some Sensor"
      wid.sensors.should == []
    end
  end

  describe "#process_args" do
    it "should set sensor by :sensor param" do
      w.process_args :sensor => :sss
      sensors = w.to_widget.sensors
      sensors.size.should == 1
      sensors.first.name.to_s.should == 'sss'
    end

    it "should set title by :title param" do
      w.process_args :title => 'Title XXX'
      w.to_widget.title.should == 'Title XXX'
    end

    it "should set width by :width param" do
      w.process_args :width => 55
      w.to_widget.width.should == 55
    end
  end

  describe "#sensor" do
    it "should add sensor" do
      w.sensor :s1
      w.sensor :s2
      sensors = w.to_widget.sensors
      sensors.size.should == 2
      sensors.first.name.to_s.should == 's1'
      sensors.last.name.to_s.should == 's2'
    end
  end

  describe "#title" do
    it "should set title" do
      w.title 'Title XXX'
      w.to_widget.title.should == 'Title XXX'
      w.title 'Title YYY'
      w.to_widget.title.should == 'Title YYY'
    end
  end

  describe "#width" do
    it "should set width" do
      w.width 66
      w.to_widget.width.should == 66
    end
  end

  describe "#to_widget" do
    it "should convert dsl data to widget" do
      w.to_widget.should be_kind_of(PulseMeter::Visualize::Widget)
    end
  end
end

