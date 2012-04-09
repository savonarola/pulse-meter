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
end
