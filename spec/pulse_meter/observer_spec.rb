require 'spec_helper'

describe PulseMeter::Observer do

  context "instance methods observation" do
  
    class ObservedDummy
      attr_reader :count

      def initialize
        @count = 0
      end

      def incr(value = 1, &proc)
        Timecop.travel(Time.now + 1)
        @count += value
        @count += proc.call if proc
        @count
      end

      def error
        raise RuntimeError
      end
    end

    let!(:dummy) {ObservedDummy.new}
    let!(:sensor) {PulseMeter::Sensor::Counter.new(:foo)}
    before do
      [:incr, :error].each {|m| described_class.unobserve_method(ObservedDummy, m)}
    end

    def create_observer(method = :incr, increment = 1)
      described_class.observe_method(ObservedDummy, method, sensor) do |*args|
        event(increment)
      end
    end

    def remove_observer(method = :incr)
      described_class.unobserve_method(ObservedDummy, method)
    end

    describe ".observe_method" do
      it "executes block in context of sensor each time specified method of given class called" do
        create_observer
        5.times {dummy.incr}
        sensor.value.should == 5
      end
      
      it "passes arguments to observed method" do
        create_observer
        5.times {dummy.incr(10)}
        dummy.count.should == 50
      end

      it "passes methods' params to block" do
        described_class.observe_method(ObservedDummy, :incr, sensor) do |time, cnt|
          event(cnt)
        end

        5.times {dummy.incr(10)}
        sensor.value.should == 50
      end

      it "passes execution time in milliseconds to block" do
        Timecop.freeze do
          described_class.observe_method(ObservedDummy, :incr, sensor) do |time, cnt|
            event(time)
          end

          dummy.incr
          sensor.value.should >= 1000
        end
      end

      it "does not break observed method even is observer raises error" do
        described_class.observe_method(ObservedDummy, :incr, sensor) do |*args|
          raise RuntimeError
        end

        lambda {dummy.incr}.should_not raise_error
        dummy.count.should == 1
      end

      it "uses first observer in case of double observation" do
        create_observer(:incr, 1)
        create_observer(:incr, 2)
        5.times {dummy.incr}
        sensor.value.should == 5
      end

      it "keeps observed methods' errors" do
        create_observer(:error)
        lambda {dummy.error}.should raise_error(RuntimeError)
        sensor.value.should == 1
      end

      it "makes observed method return its value" do
        create_observer
        dummy.incr.should == 1
      end

      it "allows to pass blocks to observed method" do
        create_observer
        dummy.incr do
          2
        end
        dummy.count.should == 3
      end
    end

    describe ".unobserve_method" do
      it "does nothing unless method is observed" do
        lambda {remove_observer}.should_not raise_error
      end

      it "removes observation from observed method" do
        create_observer
        dummy.incr
        remove_observer
        dummy.incr
        sensor.value.should == 1
      end
    end
  end

  context "class methods observation" do
  
    class ObservedDummy
      @@count = 0
      class << self
        def count
          @@count
        end

        def reset
          @@count = 0
        end

        def incr(value = 1, &proc)
          Timecop.travel(Time.now + 1)
          @@count += value
          @@count += proc.call if proc
          @@count
        end

        def error
          raise RuntimeError
        end
      end
    end

    let!(:dummy) {ObservedDummy}
    let!(:sensor) {PulseMeter::Sensor::Counter.new(:foo)}
    before do
      dummy.reset
      [:incr, :error].each {|m| described_class.unobserve_class_method(ObservedDummy, m)}
    end

    def create_observer(method = :incr, increment = 1)
      described_class.observe_class_method(ObservedDummy, method, sensor) do |*args|
        event(increment)
      end
    end

    def remove_observer(method = :incr)
      described_class.unobserve_class_method(ObservedDummy, method)
    end

    describe ".observe_class_method" do
      it "executes block in context of sensor each time specified method of given class called" do
        create_observer
        5.times {dummy.incr}
        sensor.value.should == 5
      end
      
      it "passes arguments to observed method" do
        create_observer
        5.times {dummy.incr(10)}
        dummy.count.should == 50
      end

      it "passes methods' params to block" do
        described_class.observe_class_method(ObservedDummy, :incr, sensor) do |time, cnt|
          event(cnt)
        end

        5.times {dummy.incr(10)}
        sensor.value.should == 50
      end

      it "passes execution time in milliseconds to block" do
        Timecop.freeze do
          described_class.observe_class_method(ObservedDummy, :incr, sensor) do |time, cnt|
            event(time)
          end

          dummy.incr
          sensor.value.should == 1000
        end
      end

      it "does not break observed method even is observer raises error" do
        described_class.observe_class_method(ObservedDummy, :incr, sensor) do |*args|
          raise RuntimeError
        end

        lambda {dummy.incr}.should_not raise_error
        dummy.count.should == 1
      end

      it "uses first observer in case of double observation" do
        create_observer(:incr, 1)
        create_observer(:incr, 2)
        5.times {dummy.incr}
        sensor.value.should == 5
      end

      it "keeps observed methods' errors" do
        create_observer(:error)
        lambda {dummy.error}.should raise_error(RuntimeError)
        sensor.value.should == 1
      end

      it "makes observed method return its value" do
        create_observer
        dummy.incr.should == 1
      end

      it "allows to pass blocks to observed method" do
        create_observer
        dummy.incr do
          2
        end
        dummy.count.should == 3
      end
    end

    describe ".unobserve_class_method" do
      it "does nothing unless method is observed" do
        lambda {remove_observer}.should_not raise_error
      end

      it "removes observation from observed method" do
        create_observer
        dummy.incr
        remove_observer
        dummy.incr
        sensor.value.should == 1
      end
    end
  end
end
