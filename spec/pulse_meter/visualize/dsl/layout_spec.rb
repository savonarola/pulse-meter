require 'spec_helper'

describe PulseMeter::Visualize::DSL::Layout do
  let(:interval){ 100 }
  let(:sensor_name) { "some_sensor" }
  let!(:sensor){ PulseMeter::Sensor::Timelined::Max.new(sensor_name, :ttl => 1000, :interval => interval) }
  let(:layout){ described_class.new }

  describe '.new' do
    it "should initialize pages, title, redraw_interval" do
      l = layout.to_layout
      l.title.should == PulseMeter::Visualize::DSL::Layout::DEFAULT_TITLE
      l.redraw_interval.should == PulseMeter::Visualize::DSL::Layout::DEFAULT_REDRAW_INTERVAL
      l.pages.should == []
      l.dashboard.should be_nil
    end
  end

  describe "#page" do
    it "should add page constructed by block to pages" do
      layout.page "My Foo Page" do |p|
        p.pie :foo_widget, sensor: sensor_name
        p.chart :bar_widget do |w|
          w.sensor(sensor_name)
        end
      end
      l = layout.to_layout
      l.pages.size.should == 1
      p = l.pages.first
      p.title.should == "My Foo Page"
      p.widgets.size.should == 2
      p.widgets.first.name.should == :foo_widget
      p.widgets.last.name.should == :bar_widget
    end
  end

  describe "#dashboard" do
    it "should set dashboard constructed by block to pages" do
      layout.dashboard do |p|
        p.pie :foo_widget, sensor: sensor_name
        p.chart :bar_widget do |w|
          w.sensor(sensor_name)
        end
      end
      l = layout.to_layout
      p = l.dashboard
      p.widgets.size.should == 2
      p.widgets.first.name.should == :foo_widget
      p.widgets.last.name.should == :bar_widget
    end
  end

  describe "#title" do
    it "should set layout title" do
      layout.title "Foo Title"
      layout.to_layout.title.should == 'Foo Title'
    end
  end
  
  describe "#redraw_interval" do
    it "should set global redraw_interval" do
      layout.redraw_interval 12345
      layout.to_layout.redraw_interval.should == 12345
    end
  end

  describe "#to_layout" do
    it "should convert layout dsl data to Visualize::Layout" do
      layout.to_layout.should be_kind_of(PulseMeter::Visualize::Layout)
    end
  end
end

