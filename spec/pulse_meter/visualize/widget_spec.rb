require "spec_helper"

describe PulseMeter::Visualize::Widget do
  let(:interval){ 100 }
  let!(:a_sensor){ PulseMeter::Sensor::Timelined::Counter.new(:a_sensor, :ttl => 1000, :interval => interval, annotation: 'A') }
  let!(:b_sensor){ PulseMeter::Sensor::Timelined::Counter.new(:b_sensor, :ttl => 1000, :interval => interval, annotation: 'B') }

  let(:type) { :some_type }
  let(:widget_name){ "some_widget" }

  let(:redraw_interval){5}
  let(:values_label){'xxxx'}
  let(:width){6}
  let(:show_last_point){false}
  let(:timespan){interval * 2}
  let(:a_color){'#FF0000'}
  let(:b_color){'#FFFF00'}

  let(:interval_start){ Time.at((Time.now.to_i / interval) * interval) }

  def add_widget_settings(w)
    w.redraw_interval redraw_interval
    w.values_label values_label
    w.width width
    w.show_last_point show_last_point
    w.timespan timespan

    w.sensor :a_sensor, color: a_color
    w.sensor :b_sensor, color: b_color
  end

  let(:widgets) do
    [:line, :area, :pie].each_with_object({}) do |type, h|
      w = PulseMeter::Visualize::DSL::Widget.new(type, widget_name)
      add_widget_settings(w)
      h[type] = w.to_widget
    end
  end

  describe "#data" do
    it "should contain type, title, interval, values_label, width, show_last_point attriutes" do
      widgets.each do |k,w|
        wdata = w.data
        wdata[:type].should == k
        wdata[:title].should == widget_name
        wdata[:interval].should == redraw_interval
        wdata[:values_title].should == values_label
        wdata[:width].should == width
      end
    end

    describe "series attribute" do
      before(:each) do
        Timecop.freeze(interval_start + 1) do
          a_sensor.event(12)
          b_sensor.event(33)
        end
        Timecop.freeze(interval_start + interval + 1) do
          a_sensor.event(111)
        end
        @current_time = interval_start + 2 * interval - 1

      end
      context "pie widget" do

        it "should contain valid pie series" do

          Timecop.freeze(@current_time) do
            widgets[:pie].data[:series].should ==
              {
                data: [
                  [a_sensor.annotation, 12],
                  [b_sensor.annotation, 33]
                ],
                options: [
                  {color: a_color},
                  {color: b_color}
                ]
              }
          end

        end

        context "line, spline, area widgets" do

          it "should contain valid series" do

            Timecop.freeze(@current_time) do

              [:line, :area].each do |type|

                widget = widgets[type]
                widget.data[:series].should ==
                  {
                    titles: [a_sensor.annotation, b_sensor.annotation],
                    rows: [[interval_start.to_i * 1000, 12, 33]],
                    options: [
                      {color: a_color},
                      {color: b_color}
                    ]
                  }
              end
            end
          end

          it "should accept custom timespan", focus: true do
            Timecop.freeze(@current_time + interval) do
              [:line, :area].each do |type|
                widget = widgets[type]
                widget.data(timespan: timespan)[:series][:rows].size.should == 1
                widget.data(timespan: timespan + interval)[:series][:rows].size.should == 2
              end
            end
          end


        end
      end
    end

  end
end