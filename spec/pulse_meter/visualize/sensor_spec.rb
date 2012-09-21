require "spec_helper"

describe PulseMeter::Visualize::Sensor do
  let(:interval){ 100 }
  let(:name) { "some_sensor" }
  let(:annotation) { 'sensor descr' }
  let!(:real_sensor){ PulseMeter::Sensor::Timelined::Counter.new(name, ttl: 1000, interval: interval, annotation: annotation) }
  let(:sensor) { described_class.new(name: name) }

  let(:color){ '#ABCDEF' }
  let(:sensor_with_color) { described_class.new(name: name, color: color) }

  let(:bad_sensor) { described_class.new(name: "bad_sensor_name") }
  let(:interval_start){ Time.at((Time.now.to_i / interval) * interval) }

  describe '#last_value' do
    context "when sensor does not exist" do
      it "should raise RestoreError" do
        expect{ bad_sensor.last_value(Time.now) }.to raise_exception(PulseMeter::RestoreError)
      end
    end


    context "when sensor has no data" do
      it "should return nil" do
        sensor.last_value(Time.now).should be_nil
      end
    end

    context "when sensor has data" do
      context "when need_incomplete arg is true" do
        it "should return last value" do
          Timecop.freeze(interval_start) do
            real_sensor.event(101)
          end
          Timecop.freeze(interval_start+1) do
            sensor.last_value(Time.now, true).should == 101
          end
        end
      end

      context "when need_incomplete arg is false" do
        it "should return last complete value" do
          Timecop.freeze(interval_start) do
            real_sensor.event(101)
          end
          Timecop.freeze(interval_start + 1) do
            sensor.last_value(Time.now).should be_nil
          end
          Timecop.freeze(interval_start + interval + 1) do
            sensor.last_value(Time.now).should == 101
          end
        end
      end

    end
  end

  describe "#last_point_data" do

    context "when sensor does not exist" do
      it "should raise RestoreError" do
        expect{ bad_sensor.last_point_data(Time.now) }.to raise_exception(PulseMeter::RestoreError)
      end
    end

    it "should return last value with annotation (and color)" do
      Timecop.freeze(interval_start) do
        real_sensor.event(101)
      end
      Timecop.freeze(interval_start + 1) do
        sensor.last_point_data(Time.now, true).should == [{name: annotation, y: 101}]
        sensor.last_point_data(Time.now).should == [{name: annotation, y: nil}]
        sensor_with_color.last_point_data(Time.now, true).should == [{name: annotation, y: 101, color: color}]
        sensor_with_color.last_point_data(Time.now).should == [{name: annotation, y: nil, color: color}]
      end
    end
  end

  describe "#timeline_data" do
    before(:each) do
      Timecop.freeze(interval_start) do
        real_sensor.event(101)
      end
      Timecop.freeze(interval_start + interval) do
        real_sensor.event(55)
      end
    end

    context "when sensor does not exist" do
      it "should raise RestoreError" do
        expect{ bad_sensor.timeline_data(Time.now - interval, Time.now) }.to raise_exception(PulseMeter::RestoreError)
      end
    end


    describe "returned value" do
      it "should contain sensor annotation" do
        Timecop.freeze(interval_start + interval + 1) do
          sensor.timeline_data(Time.now - interval, Time.now).first[:name].should == annotation
        end
      end
      it "should contain sensor color" do
        Timecop.freeze(interval_start + interval + 1) do
          sensor_with_color.timeline_data(Time.now - interval, Time.now).first[:color].should == color
        end
      end

      it "should contain [interval_start, value] pairs for each interval" do
        Timecop.freeze(interval_start + interval + 1) do
          data = sensor.timeline_data(Time.now - interval * 2, Time.now)
          data.first[:data].should == [{x: interval_start.to_i * 1000, y: 101}]
          data = sensor.timeline_data(Time.now - interval * 2, Time.now, true)
          data.first[:data].should == [{x: interval_start.to_i * 1000, y: 101}, {x: (interval_start + interval).to_i * 1000, y: 55}]
        end
      end
    end
  end

end
