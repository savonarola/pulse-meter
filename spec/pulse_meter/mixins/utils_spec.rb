require 'spec_helper'

describe PulseMeter::Mixins::Utils do
  class Dummy
    include PulseMeter::Mixins::Utils
  end

  let(:dummy){ Dummy.new }

  describe '#constantize' do
    context "when argument is a string with a valid class name" do
      it "should return class" do
        dummy.constantize("PulseMeter::Mixins::Utils").should == PulseMeter::Mixins::Utils
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

    context "when no default value given" do
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

      it "should raise exception if the value is not defined" do
        expect{ dummy.assert_positive_integer!({}, :val) }.to raise_exception(ArgumentError)
      end
    end

    context "when default value given" do
      it "should prefer value from options to default" do
        dummy.assert_positive_integer!({:val => 4}, :val, 22).should == 4
      end

      it "should use default value when there is no one in options" do
        dummy.assert_positive_integer!({}, :val, 22).should == 22
      end

      it "should check default value if it is to be used" do
        expect{dummy.assert_positive_integer!({}, :val, :bad)}.to raise_exception(ArgumentError)
        expect{dummy.assert_positive_integer!({}, :val, -1)}.to raise_exception(ArgumentError)
      end
    end
  end

  describe "#assert_array!" do
    it "should extract value from hash by passed key" do
      dummy.assert_array!({:val => [:foo]}, :val).should == [:foo]
    end

    context "when no default value given" do
      it "should raise exception if th value is not an Array" do
        expect{ dummy.assert_array!({:val => :bad}, :val) }.to raise_exception(ArgumentError)
      end

      it "should raise exception if the value is not defined" do
        expect{ dummy.assert_array!({}, :val) }.to raise_exception(ArgumentError)
      end
    end

    context "when default value given" do
      it "should prefer value from options to default" do
        dummy.assert_array!({:val => [:foo]}, :val, []).should == [:foo]
      end

      it "should use default value when there is no one in options" do
        dummy.assert_array!({}, :val, []).should == []
      end

      it "should check default value if it is to be used" do
        expect{dummy.assert_array!({}, :val, :bad)}.to raise_exception(ArgumentError)
      end
    end
  end

  describe "#assert_ranged_float!" do

    it "should extract float value from hash by passed key" do
      dummy.assert_ranged_float!({:val => 4}, :val, 0, 100).should be_generally_equal(4)
    end

    context "when the value by the passed key is not float" do
      it "should convert non-floats to floats" do
        dummy.assert_ranged_float!({:val => "4.0000"}, :val, 0, 100).should be_generally_equal(4)
      end

      it "should change the original value to the obtained float" do
        h = {:val => "4.000"}
        dummy.assert_ranged_float!(h, :val, 0, 100).should be_generally_equal(4)
        h[:val].should be_generally_equal(4)
      end

      it "should raise exception if the original value cannot be converted to float" do
        expect{ dummy.assert_ranged_float!({:val => :bad_float}, :val, 0, 100) }.to raise_exception(ArgumentError)
      end
    end

    it "should raise exception if the value is not within range" do
      expect{ dummy.assert_ranged_float!({:val => -0.1}, :val, 0, 100) }.to raise_exception(ArgumentError)
      expect{ dummy.assert_ranged_float!({:val => 100.1}, :val, 0, 100) }.to raise_exception(ArgumentError)
    end

    it "should raise exception if the value is not defined" do
      expect{ dummy.assert_ranged_float!({}, :val) }.to raise_exception(ArgumentError)
    end
  end

  describe "#uniqid" do
    it "should return uniq strings" do
      uniq_values = (1..1000).map{|_| dummy.uniqid}
      uniq_values.uniq.count.should == uniq_values.count
    end
  end

  describe "#titleize" do
    it "should convert identificator to title" do
      dummy.titleize("aaa_bbb").should == 'Aaa Bbb'
      dummy.titleize(:aaa_bbb).should == 'Aaa Bbb'
      dummy.titleize("aaa bbb").should == 'Aaa Bbb'
    end
  end

  describe "#camelize" do
    it "should camelize string" do
      dummy.camelize("aa_bb_cc").should == "aaBbCc"
      dummy.camelize("aa_bb_cc", true).should == "AaBbCc"
    end
  end

  describe "#underscore" do
    it "should underscore string" do
      dummy.underscore("aaBbCc").should == "aa_bb_cc"
      dummy.underscore("AaBbCc").should == "aa_bb_cc"
      dummy.underscore("aaBb::Cc").should == "aa_bb/cc"
    end
  end

  describe "#camelize_keys" do
    it "should deeply camelize keys in hashes" do
      dummy.camelize_keys({ :aa_bb_cc => [ { :dd_ee => 123 }, 456 ] }).should =={ 'aaBbCc' => [ { 'ddEe' => 123 }, 456 ] }
    end
  end

  describe "#symbolize_keys" do
    it "should convert symbolizable keys to symbols" do
      dummy.symbolize_keys({"a" => 5, 6 => 7}).should == {a: 5, 6 => 7}
    end
  end

  describe "#subsets_of" do
    it "returns all subsets of given array" do
      dummy.subsets_of([1, 2]).sort.should == [[], [1], [2], [1, 2]].sort
    end
  end

  describe "#each_subset" do
    it "iterates over each subset" do
      subsets = []
      dummy.each_subset([1, 2]) {|s| subsets << s}
      subsets.sort.should == [[], [1], [2], [1, 2]].sort
    end
  end

  describe '#parse_time' do
    context "when argument is a valid YYYYmmddHHMMSS string" do
      it "should correct Time object" do
        t = dummy.parse_time("19700101000000")
        t.should be_kind_of(Time)
        t.to_i.should == 0
      end
    end
    context "when argument is an invalid YYYYmmddHHMMSS string" do
      it "should raise ArgumentError" do
        expect{ dummy.parse_time("19709901000000") }.to raise_exception(ArgumentError)
      end
    end
    context "when argument is not a YYYYmmddHHMMSS string" do
      it "should raise ArgumentError" do
        expect{ dummy.parse_time("197099010000000") }.to raise_exception(ArgumentError)
      end
    end
  end
end
