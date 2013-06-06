require 'spec_helper'

describe PulseMeter::Observer::Extended do
  context "instance methods observation" do
    let!(:dummy) {ObservedDummy.new}
    let!(:sensor) {PulseMeter::Sensor::Counter.new(:foo)}
    before do
      [:incr, :error].each {|m| described_class.unobserve_method(ObservedDummy, m)}
    end

    describe ".observe_method" do
      it "passes exended parameters to block in normal execution" do
        Timecop.freeze do
          parameters = {}

          described_class.observe_method(ObservedDummy, :incr, sensor) do |params|
            parameters = params
          end

          dummy.incr(40)

          parameters[:self].should == dummy
          parameters[:delta].should >= 1000
          parameters[:result].should == 40
          parameters[:exception].should be_nil
          parameters[:args].should == [40]
        end
      end

      it "passes exended parameters to block with exception" do
        Timecop.freeze do
          parameters = {}

          described_class.observe_method(ObservedDummy, :error, sensor) do |params|
            parameters = params
          end

          lambda { dummy.error }.should raise_error(RuntimeError)

          parameters[:self].should == dummy
          parameters[:result].should == nil
          parameters[:exception].class.should == RuntimeError
          parameters[:args].should == []
        end
      end
    end
  end

  context "class methods observation" do
    let!(:sensor) {PulseMeter::Sensor::Counter.new(:foo)}
    before do
      [:incr, :error].each {|m| described_class.unobserve_class_method(ObservedDummy, m)}
    end

    describe ".observe_class_method" do
      it "passes exended parameters to block in normal execution" do
        Timecop.freeze do
          parameters = {}

          described_class.observe_class_method(ObservedDummy, :incr, sensor) do |params|
            parameters = params
          end
  
          ObservedDummy.incr(40)

          parameters[:self].should == ObservedDummy
          parameters[:delta].should >= 1000
          parameters[:result].should == 40
          parameters[:exception].should be_nil
          parameters[:args].should == [40]
        end
      end

      it "passes exended parameters to block with exception" do
        Timecop.freeze do
          parameters = {}

          described_class.observe_class_method(ObservedDummy, :error, sensor) do |params|
            parameters = params
          end
  
          lambda { ObservedDummy.error }.should raise_error(RuntimeError)

          parameters[:self].should == ObservedDummy
          parameters[:result].should == nil
          parameters[:exception].class.should == RuntimeError
          parameters[:args].should == []
        end
      end
    end
  end
end