shared_examples_for "dsl widget" do

  let(:interval){ 100 }
  let(:name) { "some_sensor" }
  let!(:sensor){ PulseMeter::Sensor::Timelined::Max.new(name, :ttl => 1000, :interval => interval) }
  
  let(:widget_name){ "some_widget" }
  let(:w){ described_class.new(widget_name)  }

  describe '.new' do
    it "should set default value for width papram" do
      wid = w.to_data
      wid.width.should == PulseMeter::Visualize::DSL::Widget::MAX_WIDTH
    end

    it "should set title param from .new argument" do
      wid = w.to_data
      wid.title.should == widget_name
    end
  end

  describe "#process_args" do
    it "should set sensor by :sensor param" do
      w.process_args :sensor => :sss
      sensors = w.to_data.sensors
      sensors.size.should == 1
      sensors.first.name.to_s.should == 'sss'
    end

    it "should set title by :title param" do
      w.process_args :title => 'Title XXX'
      w.to_data.title.should == 'Title XXX'
    end

    it "should set width by :width param" do
      w.process_args :width => 5
      w.to_data.width.should == 5
    end

  end

  describe "#sensor" do
    it "should add sensor" do
      w.sensor :s1
      w.sensor :s2
      sensors = w.to_data.sensors
      sensors.size.should == 2
      sensors.first.name.to_s.should == 's1'
      sensors.last.name.to_s.should == 's2'
    end
  end

  describe "#title" do
    it "should set title" do
      w.title 'Title XXX'
      w.to_data.title.should == 'Title XXX'
      w.title 'Title YYY'
      w.to_data.title.should == 'Title YYY'
    end
  end

  describe "#width" do
    it "should set width" do
      w.width 6
      w.to_data.width.should == 6
    end

    it "should raise exception if width is invalid" do
      expect { w.width -1 }.to raise_exception(PulseMeter::Visualize::DSL::BadWidgetWidth)
      expect { w.width 11 }.to raise_exception(PulseMeter::Visualize::DSL::BadWidgetWidth)
    end
  end

  describe "#redraw_interval" do
    it "should set redraw_interval" do
      w.redraw_interval 5
      w.to_data.redraw_interval.should == 5
    end
    it "should raise exception if redraw_interval is negative" do
      expect{ w.redraw_interval(-1) }.to raise_exception(PulseMeter::Visualize::DSL::BadWidgetRedrawInterval)
    end

  end

  describe "#to_data" do
    it "should convert dsl data to widget" do
      w.to_data.should be_kind_of(PulseMeter::Visualize::Widget)
    end
  end

  describe "#gchart_options" do
    it "should add options to gchart_options hash" do
      w.gchart_options a: 1
      w.gchart_options b: 2
      w.to_data.gchart_options.should == {a: 1, b: 2}
    end
  end

  describe "any anknown method" do
    it "should add options to gchart_options hash" do
      w.foobar 123
      w.to_data.gchart_options.should == {foobar: 123}
    end
  end
end

