require "spec_helper"

describe PulseMeter::Sensor::Configuration do
  describe "#add_sensor" do
    let(:cfg) {described_class.new}

    it "should create sensor available under passed name" do
      cfg.sensor(:foo).should be_nil
      cfg.add_sensor(:foo, sensor_type: 'counter')
      cfg.sensor(:foo).should_not be_nil
    end

    it "should event shortcut for the sensor" do
      cfg.add_sensor(:foo, sensor_type: 'counter')
      sensor = cfg.sensor(:foo)
      sensor.should_receive(:event).with(321)
      cfg.foo(321)
    end

    it "should create sensor with correct type" do
      cfg.add_sensor(:foo, sensor_type: 'counter')
      cfg.sensor(:foo).should be_kind_of(PulseMeter::Sensor::Counter)
    end

    it "should raise exception if sensor type is bad" do
      expect{ cfg.add_sensor(:foo, sensor_type: 'baaaar') }.to raise_exception(ArgumentError)
    end

    it "should pass args to created sensor" do
      cfg.add_sensor(:foo, sensor_type: 'counter', args: {annotation: "My Foo Counter"} )
      cfg.sensor(:foo).annotation.should == "My Foo Counter"
    end

    it "should accept hashie-objects" do
      class Dummy
        def sensor_type
          'counter'
        end
        def args
          Hashie::Mash.new(annotation: "My Foo Counter")
        end
      end

      cfg.add_sensor(:foo, Dummy.new)
      cfg.sensor(:foo).annotation.should == "My Foo Counter"
    end


  end

  describe ".new" do
    it "should add passed sensor setting hash using keys as names" do
      opts = {
        cnt: {
          sensor_type: 'counter'
        },
        ind: {
          sensor_type: 'indicator'
        }
      }
      cfg1 = described_class.new(opts)
      cfg2 = described_class.new
      opts.each{|k,v| cfg2.add_sensor(k, v)}
      cfg1.to_yaml.should == cfg2.to_yaml
    end
  end

  describe "#sensor" do
    it "should give access to added sensors" do
      opts = {
        cnt: {
          sensor_type: 'counter',
          args: {
            annotation: "MySensor"
          }
        },
      }
      cfg = described_class.new(opts)
      cfg.sensor(:cnt).annotation.should == "MySensor"
      cfg.sensor("cnt").annotation.should == "MySensor"
    end
  end
end