require 'spec_helper'

describe PulseMeter::Visualize::DSL::Page do
  let(:interval){ 100 }
  let(:sensor_name) { "some_sensor" }
  let!(:sensor){ PulseMeter::Sensor::Timelined::Max.new(sensor_name, :ttl => 1000, :interval => interval) }
  let(:title) { "page title" }
  let(:page){ PulseMeter::Visualize::DSL::Page.new(title) }

  describe '.new' do
    it "should initialize title and widgets" do
      p = page.to_page  
      p.title.should == title
      p.widgets.should == []
    end
  end

  describe '#widget' do
    it "should add widget initialized by args to widgets" do
      page.widget(:some_widget_type, :some_widget_name, sensor: sensor_name, width: 7)
      w = page.to_page.widgets.first
      w.width.should == 7
      w.type.should == :some_widget_type
      w.title.should == "some_widget_name"
      w.sensors.first.name.should == sensor_name
    end
    
    it "should add widget initialized by block" do
      page.widget(:some_widget_type, :some_widget_name) do |w|
        w.sensor(sensor_name)
        w.sensor(sensor_name)
        w.title "foo_widget"
        w.width 7
      end
      w = page.to_page.widgets.first
      w.type.should == :some_widget_type
      w.width.should == 7
      w.title.should == "foo_widget"
      w.sensors.size.should == 2
      w.sensors.first.name.should == sensor_name
      w.sensors.last.name.should == sensor_name
    end
  end
  
  describe "#pie" do
    it "should create widget width type :pie" do
      page.pie(:some_widget_name)
      w = page.to_page.widgets.first
      w.type.should == :pie
    end
  end

  describe "#chart" do
    it "should create widget width type :chart" do
      page.line(:some_widget_name)
      w = page.to_page.widgets.first
      w.type.should == :line
    end
  end

  describe "#title" do
    it "should set page title" do
      page.title "Foo Title"
      page.to_page.title.should == 'Foo Title'
    end
  end

  describe "#to_page" do
    it "should convert DSL data to Visualize::Page" do
      page.to_page.should be_kind_of(PulseMeter::Visualize::Page)
    end
  end

end

