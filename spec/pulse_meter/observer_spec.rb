require 'spec_helper'

describe PulseMeter::Observer do

  context "instance methods observation" do
  
    class Dummy
      attr_reader :count

      def initialize
        @count = 0
      end

      def incr(value = 1)
        @count += value
      end

      def error
        raise RuntimeError
      end
    end

    let!(:dummy) {Dummy.new}
    let!(:sensor) {PulseMeter::Sensor::Counter.new(:foo)}
    before do
      [:incr, :error].each {|m| described_class.unobserve_method(Dummy, m)}
    end

    def create_observer(method = :incr, increment = 1)
      described_class.observe_method(Dummy, method, sensor) do |*args|
        event(increment)
      end
    end

    def remove_observer(method = :incr)
      described_class.unobserve_method(Dummy, method)
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
        described_class.observe_method(Dummy, :incr, sensor) do |cnt|
          event(cnt)
        end

        5.times {dummy.incr(10)}
        sensor.value.should == 50
      end

      it "does not break observed method even is observer raises error" do
        described_class.observe_method(Dummy, :incr, sensor) do |*args|
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

      #class User
      #  def create(attrs)
      #  end
      #end

      #it "foo", :focus => true do
      #  h = PulseMeter::Sensor::HashedCounter.new :h
      #  described_class.observe_method(User, :create, h) do |attrs|
      #    event({attrs[:name] => 1})
      #  end
      #
      #  User.new.create :name => :a
      #  User.new.create :name => :a
      #  User.new.create :name => :b
      #  puts h.value.inspect
      #  
      #end
    end
  end

  context "class methods observation" do
  
    class Dummy
      @@count = 0
      class << self
        def count
          @@count
        end

        def reset
          @@count = 0
        end

        def incr(value = 1)
          @@count += value
        end

        def error
          raise RuntimeError
        end
      end
    end

    let!(:dummy) {Dummy}
    let!(:sensor) {PulseMeter::Sensor::Counter.new(:foo)}
    before do
      dummy.reset
      [:incr, :error].each {|m| described_class.unobserve_class_method(Dummy, m)}
    end

    def create_observer(method = :incr, increment = 1)
      described_class.observe_class_method(Dummy, method, sensor) do |*args|
        event(increment)
      end
    end

    def remove_observer(method = :incr)
      described_class.unobserve_class_method(Dummy, method)
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
        described_class.observe_class_method(Dummy, :incr, sensor) do |cnt|
          event(cnt)
        end

        5.times {dummy.incr(10)}
        sensor.value.should == 50
      end

      it "does not break observed method even is observer raises error" do
        described_class.observe_class_method(Dummy, :incr, sensor) do |*args|
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

      #class User
      #  def create(attrs)
      #  end
      #end

      #it "foo", :focus => true do
      #  h = PulseMeter::Sensor::HashedCounter.new :h
      #  described_class.observe_method(User, :create, h) do |attrs|
      #    event({attrs[:name] => 1})
      #  end
      #
      #  User.new.create :name => :a
      #  User.new.create :name => :a
      #  User.new.create :name => :b
      #  puts h.value.inspect
      #  
      #end
    end
  end
end
