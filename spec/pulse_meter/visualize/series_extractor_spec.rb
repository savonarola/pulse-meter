require "spec_helper"

describe PulseMeter::Visualize::SeriesExtractor do
  let(:interval){ 100 }
  let!(:real_simple_sensor){ PulseMeter::Sensor::Timelined::Counter.new(:simple_sensor,
    ttl: 1000,
    interval: interval,
    annotation: 'simple sensor'
  ) }
  let!(:real_hashed_sensor){ PulseMeter::Sensor::Timelined::HashedCounter.new(:hashed_sensor,
    ttl: 1000,
    interval: interval,
    annotation: 'hashed sensor'
  ) }

  let!(:simple_sensor){PulseMeter::Visualize::Sensor.new(sensor: :simple_sensor)}
  let!(:hashed_sensor){PulseMeter::Visualize::Sensor.new(sensor: :hashed_sensor)}

  describe "simple extractor" do

    let(:extractor) {PulseMeter::Visualize.extractor(simple_sensor)}

    it "should be created for simple sensors" do
      extractor.should be_kind_of(PulseMeter::Visualize::SeriesExtractor::Simple)
    end

    it "should create point data correctly" do
      extractor.point_data(123).should == {y: 123, name: 'simple sensor'}
    end

    it "should create timeline data correctly" do
      tl_data = [
        PulseMeter::SensorData.new(Time.at(1), 11),
        PulseMeter::SensorData.new(Time.at(2), "22")
      ]
      extractor.series_data(tl_data).should == {
        name: 'simple sensor',
        data: [{x: 1000, y: 11}, {x: 2000, y: 22}]
      }
    end

  end

  describe "hash extractor" do
    let(:extractor) {PulseMeter::Visualize.extractor(hashed_sensor)}

    it "should be created for hash sensors" do
      extractor.should be_kind_of(PulseMeter::Visualize::SeriesExtractor::Hashed)
    end

    it "should create point data correctly" do
      extractor.point_data('{"x": 123, "y": 321}').should == [
        {y: 123, name: 'x'},
        {y: 321, name: 'y'}
      ]
    end

    it "should create timeline data correctly" do
      tl_data = [
        PulseMeter::SensorData.new(Time.at(1), {"a" => 5, "b" => 6}),
        PulseMeter::SensorData.new(Time.at(2), '{"c": 7, "b": 6}')
      ]
      extractor.series_data(tl_data).should == [
        {
          name: 'a',
          data: [{x: 1000, y: 5}, {x: 2000, y: nil}]
        },
        {
          name: 'b',
          data: [{x: 1000, y: 6}, {x: 2000, y: 6}]
        },
        {
          name: 'c',
          data: [{x: 1000, y: nil}, {x: 2000, y: 7}]
        }
      ]
    end
  end

end