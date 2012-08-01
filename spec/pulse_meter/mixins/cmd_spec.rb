require 'spec_helper'

describe PulseMeter::Mixins::Cmd do
  class Dummy
    extend PulseMeter::Mixins::Cmd

    def self.options
      {host: :localhost, port: 6379, db: 0}
    end
  end

  let(:dummy){ Dummy }
  before {PulseMeter.redis = Redis.new}

  describe "#fail!" do
    it "prints given message and exits" do
      STDOUT.should_receive(:puts).with(:msg)
      lambda {dummy.fail!(:msg)}.should raise_error(SystemExit)
    end
  end

  describe '#with_redis' do
    it "initializes redies and yields a block" do
      PulseMeter.redis = nil
      dummy.with_redis do
        PulseMeter.redis.should_not be_nil
      end
    end
  end

  describe "#with_safe_restore_of" do
    it "restores sensor by name and passes it to block" do
      sensor = PulseMeter::Sensor::Counter.new(:foo)
      dummy.with_safe_restore_of(:foo) do |s|
        s.should be_instance_of(sensor.class)
      end
    end

    it "prints error and exits if sensor cannot be restored" do
      STDOUT.should_receive(:puts).with("Sensor nonexistant is unknown or cannot be restored")
      lambda {dummy.with_safe_restore_of(:nonexistant) {|s| s}}.should raise_error(SystemExit)
    end
  end

  describe "#all_sensors" do
    it "is just an alias to PulseMeter::Sensor::Timeline.list_objects" do
      PulseMeter::Sensor::Timeline.should_receive(:list_objects)
      dummy.all_sensors
    end
  end

  describe "#all_sensors_table" do
    before {PulseMeter.redis.flushall}
    let(:init_values){ {:ttl => 1, :raw_data_ttl => 2, :interval => 3, :reduce_delay => 4} }
    let!(:s1) {PulseMeter::Sensor::Counter.new(:s1)} 
    let!(:s2) {PulseMeter::Sensor::Timelined::Counter.new(:s2, init_values)} 
    let!(:table) {dummy.all_sensors_table}
    let!(:csv) {dummy.all_sensors_table(:csv)}
    let!(:parsed_csv) {CSV.parse(csv, col_sep: ";")}

    def rows(format)
      if "csv" == format.to_s
        parsed_csv
      else
        table.rows.map do |row|
          row.cells.map(&:to_s).map(&:strip)
        end
      end
    end

    def sensor_row(name, format)
      rows(format).select {|row| row[0] == name}.first
    end
      
    [:csv, :table].each do |format|
      context "when format is #{format}" do

        if "csv" == format.to_s
          it "returns csv as string" do
            csv.should be_instance_of(String)
          end
        else
          it "returns Terminal::Table instance" do
            table.should be_instance_of(Terminal::Table)
          end
        end

        it "has title row" do
          rows(format)[0].should == ["Name", "Class", "ttl", "raw data ttl", "interval", "reduce delay"]
        end

        it "has one row for each sensor (and a title)" do
          rows(format).count.should == 3
        end

        it "can display timelined sensors" do
          sensor_row("s2", format).should == [
            s2.name, s2.class, s2.ttl, s2.raw_data_ttl, s2.interval, s2.reduce_delay
          ].map(&:to_s)
        end

        it "can display static sensors" do
          sensor_row("s1", format).should == [
            s1.name, s1.class, "", "", "", ""
          ].map(&:to_s)
        end

      end
    end
  end

end
