require 'spec_helper'
require 'pulse-meter/extensions/enumerable'

describe Enumerable do
  let!(:time) {Time.new}
  describe "#convert_time" do
    it "converts Time objects to unixtime" do
      [time].convert_time.should == [time.to_i]
    end

    it "does not change other members" do
      [1, 2, 3].convert_time.should == [1, 2 ,3]
    end
  end

  describe "#to_table" do
    context "when format is csv" do
      it "returns csv as string" do
        [].to_table(:csv).should be_instance_of(String)
      end

      it "returns csv containing each subarray as a row" do
        [[:a, :b], [:c, :d]].to_table(:csv).should == "a;b\nc;d\n"
      end

      it "converts Time objects to unixtime" do
        [[time]].to_table(:csv).should == "#{time.to_i}\n"
      end

      it "takes format argument both as string and as symbol" do
        [[:foo]].to_table("csv").should == "foo\n"
        [[:foo]].to_table(:csv).should == "foo\n"
      end
    end

    context "when format is table" do
      it "return Terminal::Table instance" do
        [].to_table.should be_instance_of(Terminal::Table)
      end

      it "returns table containing each subarray as a row" do
        data = [[:a, :b], [:c, :d]]
        table = [[:a, :b], [:c, :d]].to_table
        table.rows.map do |row|
          row.cells.map(&:to_s).map(&:strip).map(&:to_sym)
        end.should == data
      end
    end

    it "uses table format as default" do
      [].to_table.should be_instance_of(Terminal::Table)
    end

    it "uses table format unless it is :csv or 'csv'" do
      [].to_table(:unknown_format).should be_instance_of(Terminal::Table)
    end
  end
end
