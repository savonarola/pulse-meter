require 'spec_helper'

describe PulseMeter::Visualize::DSL::Widget do
  include_context :dsl

  let(:interval){ 100 }
  let(:name) { :sensor_name }
  let!(:sensor){ PulseMeter::Sensor::Timelined::Max.new(name, :ttl => 1000, :interval => interval) }

  let(:type) { :some_type }
  let(:widget_name){ "some_widget" }
  let(:w){ described_class.new(type, widget_name)  }

  describe '.new' do
    it "should raise exception if type arg is empty" do
      lambda{ described_class.new('', widget_name) }.should raise_exception(PulseMeter::Visualize::DSL::BadWidgetType)
    end

    it "should set default values for name, title, width, values_label. redraw_interval, show_last_point paprams" do
      wid = w.to_widget
      wid.type.should == :some_type
      wid.width.should == PulseMeter::Visualize::DSL::Widget::DEFAULT_WIDTH
      wid.title.should == widget_name
      wid.sensors.should == []
      wid.values_label.should == ''
      wid.redraw_interval.should be_nil
      wid.show_last_point.should be_false
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
      w.process_args :width => 5
      w.to_widget.width.should == 5
    end

    it "should set values_label by :values_label param" do
      w.process_args :values_label => "some y-axis legend"
      w.to_widget.values_label.should == "some y-axis legend"
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
      w.width 6
      w.to_widget.width.should == 6
    end

    it "should raise exception if width is invalid" do
      expect { w.width -1 }.to raise_exception(PulseMeter::Visualize::DSL::BadWidgetWidth)
      expect { w.width 11 }.to raise_exception(PulseMeter::Visualize::DSL::BadWidgetWidth)
    end
  end

  describe "#values_label" do
    it "should set values_label" do
      w.values_label "some y-axis legend"
      w.to_widget.values_label.should == "some y-axis legend"
    end
  end

  describe "#show_last_point" do
    it "should set show_last_point" do
      w.show_last_point true
      w.to_widget.show_last_point.should be_true
    end
  end

  describe "#redraw_interval" do
    it "should set redraw_interval" do
      w.redraw_interval 5
      w.to_widget.redraw_interval.should == 5
    end
    it "should raise exception if redraw_interval is negative" do
      expect{ w.redraw_interval(-1) }.to raise_exception(PulseMeter::Visualize::DSL::BadWidgetRedrawInterval)
    end

  end

  describe "#timespan" do
    it "should set timespan" do
      w.timespan 5
      w.to_widget.timespan.should == 5
    end
    it "should raise exception if timespan is negative" do
      expect{ w.timespan(-1) }.to raise_exception(PulseMeter::Visualize::DSL::BadWidgetTimeSpan)
    end

  end

  describe "#to_widget" do
    it "should convert dsl data to widget" do
      w.to_widget.should be_kind_of(PulseMeter::Visualize::Widget)
    end
  end
end

