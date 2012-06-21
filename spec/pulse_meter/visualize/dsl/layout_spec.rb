require 'spec_helper'

describe PulseMeter::Visualize::DSL::Layout do
  let(:interval){ 100 }
  let(:sensor_name) { "some_sensor" }
  let!(:sensor){ PulseMeter::Sensor::Timelined::Max.new(sensor_name, :ttl => 1000, :interval => interval) }
  let(:layout){ described_class.new }

  describe '.new' do
    it "should initialize pages, title, use_utc, gchart_options" do
      l = layout.to_layout
      l.title.should == PulseMeter::Visualize::DSL::Layout::DEFAULT_TITLE
      l.pages.should == []
      l.use_utc.should be_true
      l.gchart_options.should == {}
    end
  end

  describe "#page" do
    it "should add page constructed by block to pages" do
      layout.page "My Foo Page" do |p|
        p.pie "foo_widget", sensor: sensor_name
        p.line "bar_widget" do |w|
          w.sensor(sensor_name)
        end
      end
      l = layout.to_layout
      l.pages.size.should == 1
      p = l.pages.first
      p.title.should == "My Foo Page"
      p.widgets.size.should == 2
      p.widgets.first.title.should == "foo_widget"
      p.widgets.last.title.should == "bar_widget"
    end
  end

  describe "#title" do
    it "should set layout title" do
      layout.title "Foo Title"
      layout.to_layout.title.should == 'Foo Title'
    end
  end

  describe "#use_utc" do
    it "should set use_utc" do
      layout.use_utc false
      layout.to_layout.use_utc.should be_false
    end
  end

  describe "#gchart_options" do
    it "should set gchart_options" do
      layout.gchart_options({b: 1})
      layout.to_layout.gchart_options.should == {b: 1}
    end
  end

  describe "#to_layout" do
    it "should convert layout dsl data to Visualize::Layout" do
      layout.to_layout.should be_kind_of(PulseMeter::Visualize::Layout)
    end
  end
end

