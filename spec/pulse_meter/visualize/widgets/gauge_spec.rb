require "spec_helper"

describe PulseMeter::Visualize::Widgets::Gauge do
  let(:interval){ 100 }
  let!(:a_sensor){PulseMeter::Sensor::Indicator.new(:a_sensor, annotation: 'A')}
  let!(:b_sensor){PulseMeter::Sensor::Indicator.new(:b_sensor, annotation: 'B')}

  let(:widget_name){ "some_widget" }

  let(:redraw_interval){5}
  let(:width){6}

  let(:interval_start){ Time.at((Time.now.to_i / interval) * interval) }

  let(:widget) do
    w = PulseMeter::Visualize::DSL::Widgets::Gauge.new(widget_name)
    w.redraw_interval redraw_interval
    w.width width
    w.sensor :a_sensor
    w.sensor :b_sensor
    w.gchart_options a: 1
    w.to_data
  end

  describe "#data" do
    it "should contain type, title, redraw_interval, width, gchart_options attriutes" do
      wdata = widget.data
      wdata[:type].should == 'gauge'
      wdata[:title].should == widget_name
      wdata[:redraw_interval].should == redraw_interval
      wdata[:width].should == width
      wdata[:gchart_options].should == {a: 1}
    end

    describe "series attribute" do
      before(:each) do
        a_sensor.event(12)
        b_sensor.event(33)
      end

      it "should contain valid gauge slices" do

        widget.data[:series].should == [
          [a_sensor.annotation, 12],
          [b_sensor.annotation, 33]
        ]

      end

    end
  end
end




