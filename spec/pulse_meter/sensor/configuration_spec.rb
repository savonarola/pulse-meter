require "spec_helper"

describe PulseMeter::Sensor::Configuration do
  let(:counter_config) {
    {
      cnt: {
        sensor_type: 'counter',
        args: {
          annotation: "MySensor"
        }
      },
    }
  }

  describe "#add_sensor" do
    let(:cfg) {described_class.new}

    it "should create sensor available under passed name" do
      cfg.has_sensor?(:foo).should be_false
      cfg.add_sensor(:foo, sensor_type: 'counter')
      cfg.has_sensor?(:foo).should_not be_true
    end

    it "should have event shortcut for the sensor" do
      cfg.add_sensor(:foo, sensor_type: 'counter')
      puts cfg.to_yaml
      cfg.sensor(:foo){|s| s.should_receive(:event).with(321)}
      cfg.foo(321)
    end
    
    it "should have event_at shortcut for the sensor" do
      cfg.add_sensor(:foo, sensor_type: 'counter')
      now = Time.now
      cfg.sensor(:foo) do |sensor|
        sensor.should_receive(:event_at).with(now, 321)
      end
      cfg.foo_at(now, 321)
    end

    it "should create sensor with correct type" do
      cfg.add_sensor(:foo, sensor_type: 'counter')
      cfg.sensor(:foo){|s| s.should be_kind_of(PulseMeter::Sensor::Counter)}
    end

    it "should not raise exception if sensor type is bad" do
      expect{ cfg.add_sensor(:foo, sensor_type: 'baaaar') }.not_to raise_exception
    end

    it "should pass args to created sensor" do
      cfg.add_sensor(:foo, sensor_type: 'counter', args: {annotation: "My Foo Counter"} )
      cfg.sensor(:foo){|s| s.annotation.should == "My Foo Counter" }
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
      cfg.sensor(:foo){|s| s.annotation.should == "My Foo Counter"}
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
      cfg1.sensors.to_yaml.should == cfg2.sensors.to_yaml
    end
  end

  describe "#sensor" do
    it "should give access to added sensors via block" do
      cfg = described_class.new(counter_config)
      cfg.sensor(:cnt){ |s| s.annotation.should == "MySensor" }
      cfg.sensor("cnt"){ |s| s.annotation.should == "MySensor" }
    end
  end

  describe "#each_sensor" do
    it "yields block for each name/sensor pair" do
      cfg = described_class.new(counter_config)
      sensors = {}
      cfg.each {|s| sensors[s.name.to_sym] = s}
      sensor = cfg.sensor(:cnt){|s| s}
      sensors.should == {:cnt => sensor}
    end
  end
end
