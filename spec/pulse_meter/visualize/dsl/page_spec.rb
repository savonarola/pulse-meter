require 'spec_helper'

describe PulseMeter::Visualize::DSL::Page do
  let(:interval){ 100 }
  let(:sensor_name) { "some_sensor" }
  let!(:sensor){ PulseMeter::Sensor::Timelined::Max.new(sensor_name, :ttl => 1000, :interval => interval) }
  let(:title) { "page title" }
  let(:page){ PulseMeter::Visualize::DSL::Page.new(title) }

  describe '.new' do
    it "should initialize title and widgets" do
      p = page.to_data  
      p.title.should == title
      p.widgets.should == []
    end
  end

  [:area, :line, :table, :pie, :gauge].each do |widget_type|

    describe "##{widget_type}" do
      it "should add #{widget_type} widget initialized by args to widgets" do
        page.send(widget_type, :some_widget_name, sensor: sensor_name, width: 7)
        w = page.to_data.widgets.first
        w.width.should == 7
        w.title.should == "some_widget_name"
        w.sensors.first.name.should == sensor_name
      end
      
      it "should add #{widget_type} widget initialized by block" do
        page.send(widget_type, :some_widget_name) do |w|
          w.sensor(sensor_name)
          w.sensor(sensor_name)
          w.title "foo_widget"
          w.width 7
        end
        w = page.to_data.widgets.first
        w.type.should == widget_type.to_s
        w.width.should == 7
        w.title.should == "foo_widget"
        w.sensors.size.should == 2
        w.sensors.first.name.should == sensor_name
        w.sensors.last.name.should == sensor_name
      end
    end
  
  end

  describe "#title" do
    it "should set page title" do
      page.title "Foo Title"
      page.to_data.title.should == 'Foo Title'
    end
  end

  describe "#to_data" do
    it "should convert DSL data to Visualize::Page" do
      page.to_data.should be_kind_of(PulseMeter::Visualize::Page)
    end
  end

end

