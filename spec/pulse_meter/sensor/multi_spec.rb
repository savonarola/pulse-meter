require 'spec_helper'

describe PulseMeter::Sensor::Multi do
  let(:name){ :multi }
  let(:annotation) { "Multi sensor" }
  let(:type) {'counter'}
  let(:factors) {[:f1, :f2]}
  let(:configuration) {
    {
      sensor_type: type,
      args: {
        annotation: annotation
      }
    }
  }
  let(:init_values) { { factors: factors, configuration: configuration } }
  let!(:sensor) { described_class.new(name, init_values) }
  let!(:redis){ PulseMeter.redis }

  describe '#initialize' do
    context "when factors are not corretly passed" do
      it "raises ArgumentError" do
        expect {described_class.new(name, {factors: :not_array, configuration: configuration})}.to raise_exception(ArgumentError)
        expect {described_class.new(name, {configuration: configuration})}.to raise_exception(ArgumentError)
      end
    end

    context "when configuration missing" do
      it "raises ArgumentError" do
        expect {described_class.new(name, {factors: factors})}.to raise_exception(ArgumentError)
      end
    end
  end

  describe "#factors" do
    it "returns factors passed to constructor" do
      sensor.factors.should == factors
    end
  end

  describe "#configuration_options" do
    it "returns configuration option passed to constructor" do
      sensor.configuration_options.should == configuration
    end
  end

  describe "#sensors" do
    it "returns PulseMeter::Sensor::Configuration instance" do
      sensor.sensors.should be_instance_of(PulseMeter::Sensor::Configuration)
    end

    it "returns class attribute" do
      another_sensor = described_class.new("another_sensor", init_values)
      another_sensor.sensors.object_id.should == sensor.sensors.object_id
    end
  end

  describe ".flush!" do
    it "makes class forget all previously created sensors" do
      sensor.event({f1: :v1, f2: :v2}, 1)
      described_class.flush!
      sensor.sensors.to_a.should == []
    end
  end

  describe "#event" do
    before {described_class.flush!}

    it "raises ArgumentError unless all factors' values given" do
      expect {sensor.event({f1: :v1}, 1)}.to raise_exception(ArgumentError)
    end


    context "when sensors must be created" do
      let(:factor_values) { {f1: :v1, f2: :v2} }

      it "implicitly creates them" do
        expect {sensor.event(factor_values, 1)}.to change{sensor.sensors.to_a.count}
      end

      it "assign names based on factors' names and values" do
        sensor.event(factor_values, 1)
        names = sensor.sensors.to_a.map(&:name)
        names.sort.should == [
          "#{name}",
          "#{name}_f1_v1",
          "#{name}_f2_v2",
          "#{name}_f1_v1_f2_v2"
        ].sort
      end

      it "creates sensors of given type with configuration options passed" do
        sensor.event(factor_values, 1)
        sensor.sensors.each do |s|
          s.should be_instance_of(PulseMeter::Sensor::Counter)
          s.annotation.should == annotation
        end
      end
    end

    it "sends event to all combinations of factors and values" do
      sensor.event({f1: :f1v1, f2: :f2v1}, 1)
      sensor.event({f1: :f1v2, f2: :f2v1}, 2)
      [
        ["#{name}", 3],
        ["#{name}_f1_f1v1", 1],
        ["#{name}_f1_f1v2", 2],
        ["#{name}_f2_f2v1", 3],
        ["#{name}_f1_f1v1_f2_f2v1", 1],
        ["#{name}_f1_f1v2_f2_f2v1", 2]
      ].each do |sensor_name, sum|
        s = sensor.sensor(sensor_name)
        s.value.should == sum
      end
    end
  end

end
