require 'spec_helper'

describe PulseMeter::Utils do
  class Dummy
    include PulseMeter::Utils
  end

  let(:dummy){ Dummy.new }

  describe '#constantize' do
    context "when argument is a string with a valid class name" do
      it "should return class" do
        dummy.constantize("PulseMeter::Utils").should == PulseMeter::Utils
      end
    end
    context "when argument is a string with invalid class name" do
      it "should return nil" do
        dummy.constantize("Pumpkin::Eater").should be_nil
      end
    end
    context "when argument is not a string" do
      it "should return nil" do
        dummy.constantize({}).should be_nil
      end
    end
  end

  describe "#assert_positive_integer!" do
    it "should extract integer value from hash by passed key" do
      dummy.assert_positive_integer!({:val => 4}, :val).should == 4
    end

    context "when the value by the passed key is not integer" do
      it "should convert non-integers to integers" do
        dummy.assert_positive_integer!({:val => 4.4}, :val).should == 4
      end

      it "should change the original value to the obtained integer" do
        h = {:val => 4.4}
        dummy.assert_positive_integer!(h, :val).should == 4
        h[:val].should == 4
      end

      it "should raise exception if the original value cannot be converted to integer"do
        expect{ dummy.assert_positive_integer!({:val => :bad_int}, :val) }.to raise_exception(ArgumentError)
      end
    end

    it "should raise exception if the value is not positive" do
        expect{ dummy.assert_positive_integer!({:val => -1}, :val) }.to raise_exception(ArgumentError)
    end
  end

end
