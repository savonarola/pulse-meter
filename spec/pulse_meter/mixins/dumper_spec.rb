require 'spec_helper'

describe PulseMeter::Mixins::Dumper do
  class Base
    include PulseMeter::Mixins::Dumper
  end

  class Bad < Base; end

  class Good < Base
    attr_accessor :some_value
    attr_accessor :name

    def redis; PulseMeter.redis; end

    def initialize(name)
      @name = name.to_s
      @some_value = name
    end
  end

  class GoodButAnother < Good; end

  let(:bad_obj){ Bad.new }
  let(:good_obj){ Good.new(:foo) }
  let(:another_good_obj){ Good.new(:bar) }
  let(:good_obj_of_another_type){ GoodButAnother.new(:quux) }
  let(:redis){ PulseMeter.redis }

  describe '#dump' do
    context "when class violates dump contract" do
      context "when it has no name attribute" do
        it "should raise exception" do
          def bad_obj.redis; PulseMeter.redis; end
          expect{ bad_obj.dump! }.to raise_exception(PulseMeter::DumpError)
        end
      end

      context "when it has no redis attribute" do
        it "should raise exception" do
          def bad_obj.name; :foo; end
          expect{ bad_obj.dump! }.to raise_exception(PulseMeter::DumpError)
        end
      end

      context "when redis is not avalable" do
        it "should raise exception" do
          def bad_obj.name; :foo; end
          def bad_obj.redis; nil; end
          expect{ bad_obj.dump! }.to raise_exception(PulseMeter::DumpError)
        end
      end
    end

    context "when class follows dump contract" do
      it "should not raise dump exception" do
        expect {good_obj.dump!}.not_to raise_exception(PulseMeter::DumpError)
      end

      it "should save dump to redis" do
        expect {good_obj.dump!}.to change {redis.hlen(Good::DUMP_REDIS_KEY)}.by(1)
      end
    end

    context "when dump is safe" do
      it "should not overwrite stored objects of the same type" do
        good_obj.some_value = 123
        good_obj.dump!
        good_obj.some_value = 321
        good_obj.dump!
        Base.restore(good_obj.name).some_value.should == 123
      end

      it "should raise DumpConflictError exception if sensor with the same name but different type already exists" do
        good_obj.name = "duplicate_name"
        good_obj_of_another_type.name = "duplicate_name"
        good_obj.dump!
        expect{good_obj_of_another_type.dump!}.to raise_exception(PulseMeter::DumpConflictError)
      end
    end
  end

  describe ".restore" do
    context "when object has never been dumped" do
      it "should raise exception" do
        expect{ Base.restore(:nonexistant) }.to raise_exception(PulseMeter::RestoreError)
      end
    end

    context "when object was dumped" do
      before do
        good_obj.dump!
      end

      it "should keep object class" do
        Base.restore(good_obj.name).should be_instance_of(good_obj.class)
      end

      it "should restore object data" do
        restored = Base.restore(good_obj.name)
        restored.some_value.should == good_obj.some_value
      end

      it "should restore last dumped object" do
        good_obj.some_value = :bar
        good_obj.dump!(false)
        restored = Base.restore(good_obj.name)
        restored.some_value.should == :bar
      end
    end
  end

  describe ".list_names" do
    context "when redis is not available" do
      before do
        PulseMeter.stub(:redis).and_return(nil)
      end

      it "should raise exception" do
        expect {Base.list_names}.to raise_exception(PulseMeter::RestoreError)
      end
    end

    context "when redis if fine" do
      it "should return empty list if nothing is registered" do
        Base.list_names.should == []
      end

      it "should return list of registered objects" do
        good_obj.dump!(false)
        another_good_obj.dump!(false)
        Base.list_names.should =~ [good_obj.name, another_good_obj.name]
      end
    end
  end

  describe ".list_objects" do
    before do
      good_obj.dump!
      another_good_obj.dump!
    end

    it "should return restored objects" do
      objects = Base.list_objects
      objects.map(&:name).should =~ [good_obj.name, another_good_obj.name]
    end

    it "should skip unrestorable objects" do
      Base.stub(:list_names).and_return([good_obj.name, "scoundrel", another_good_obj.name])
      objects = Base.list_objects
      objects.map(&:name).should =~ [good_obj.name, another_good_obj.name]
    end
  end

  describe "#cleanup_dump" do
    it "should remove data from redis" do
      good_obj.dump!
      another_good_obj.dump!
      expect {good_obj.cleanup_dump}.to change{good_obj.class.list_names.count}.by(-1)
    end
  end
end
