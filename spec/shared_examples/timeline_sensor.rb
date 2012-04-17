shared_examples_for "timeline sensor" do
  let(:name){ :some_value_with_history }
  let(:ttl){ 100 }
  let(:raw_data_ttl){ 30 }
  let(:interval){ 5 }
  let(:reduce_delay){ 3 }
  let(:good_init_values){ {:ttl => ttl, :raw_data_ttl => raw_data_ttl, :interval => interval, :reduce_delay => reduce_delay} }
  let!(:sensor){ described_class.new(name, good_init_values) }
  let(:redis){ PulseMeter.redis }

  before(:each) do
    @interval_id = (Time.now.to_i / interval) * interval
    @raw_data_key = sensor.raw_data_key(@interval_id) 
    @next_raw_data_key = sensor.raw_data_key(@interval_id + interval)
    @start_of_interval = Time.at(@interval_id)
  end

  describe "#event" do
    it "should write events to redis" do
      expect{
          sensor.event(123)
      }.to change{ redis.keys('*').count }.by(1)
    end

    it "should write data so that it totally expires after :raw_data_ttl" do
      key_count = redis.keys('*').count
      sensor.event(123)
      Timecop.freeze(Time.now + raw_data_ttl + 1) do
        redis.keys('*').count.should == key_count
      end
    end

    it "should write data to bucket indicated by truncated timestamp" do
      key = sensor.raw_data_key(@interval_id)
      expect{
        Timecop.freeze(@start_of_interval) do
          sensor.event(123)
        end
      }.to change{ redis.ttl(key) }
    end
  end

  describe "#summarize" do
    it "should convert data stored by raw_data_key to a value defined only by stored data" do
      Timecop.freeze(@start_of_interval) do
        sensor.event(123)
      end
      Timecop.freeze(@start_of_interval + interval) do
        sensor.event(123)
      end
      sensor.summarize(@raw_data_key).should == sensor.summarize(@next_raw_data_key)
      sensor.summarize(@raw_data_key).should_not be_nil
    end
  end

  describe "#reduce" do
    it "should store summarized value into data_key" do
      Timecop.freeze(@start_of_interval){ sensor.event(123) }
      val = sensor.summarize(@raw_data_key)
      val.should_not be_nil
      sensor.reduce(@interval_id)
      redis.get(sensor.data_key(@interval_id)).should == val.to_s
    end

    it "should remove original raw_data_key" do
      Timecop.freeze(@start_of_interval){ sensor.event(123) }
      expect{
        sensor.reduce(@interval_id)
      }.to change{ redis.keys(sensor.raw_data_key(@interval_id)).count }.from(1).to(0)
    end

    it "should expire stored summarized data" do
      Timecop.freeze(@start_of_interval) do
        sensor.event(123)
        sensor.reduce(@interval_id)
        redis.keys(sensor.data_key(@interval_id)).count.should == 1
      end
      Timecop.freeze(@start_of_interval + ttl + 1) do
        redis.keys(sensor.data_key(@interval_id)).count.should == 0
      end
    end

    it "should not store data if there is no corresponding raw data" do
      Timecop.freeze(@start_of_interval) do
        sensor.reduce(@interval_id)
        redis.keys(sensor.data_key(@interval_id)).count.should == 0
      end
    end
  end

  describe "#reduce_all_raw" do
    it "should reduce all data older than reduce_delay" do
      Timecop.freeze(@start_of_interval){ sensor.event(123) }
      val0 = sensor.summarize(@raw_data_key)
      Timecop.freeze(@start_of_interval + interval){ sensor.event(123) }
      val1 = sensor.summarize(@next_raw_data_key)
      expect{
        Timecop.freeze(@start_of_interval + interval + interval + reduce_delay + 1) { sensor.reduce_all_raw }
      }.to change{ redis.keys(sensor.raw_data_key('*')).count }.from(2).to(0)

      redis.get(sensor.data_key(@interval_id)).should == val0.to_s
      redis.get(sensor.data_key(@interval_id + interval)).should == val1.to_s
    end

    it "should not reduce fresh data" do
      Timecop.freeze(@start_of_interval){ sensor.event(123) }

      expect{
        Timecop.freeze(@start_of_interval + interval + reduce_delay - 1) { sensor.reduce_all_raw }
      }.not_to change{ redis.keys(sensor.raw_data_key('*')).count }

      expect{
        Timecop.freeze(@start_of_interval + interval + reduce_delay - 1) { sensor.reduce_all_raw }
      }.not_to change{ redis.keys(sensor.data_key('*')).count }
    end
  end

  describe "#timeline" do
    it "should return an array of SensorData objects corresponding to stored data for passed interval" do
      sensor.event(123)
      timeline = sensor.timeline(1)
      timeline.should be_kind_of(Array)
      timeline.each{|i| i.should be_kind_of(SensorData) }
    end

    it "should raise exception if passed interval is not a positive integer" do
      [:q, nil, -1].each do |bad_interval|
        expect{ sensor.timeline(bad_interval) }.to raise_exception(ArgumentError)
      end
    end

    it "should return array of results containing as many results as there are sensor interval beginnings in the passed interval" do
      Timecop.freeze(@start_of_interval){ sensor.event(123) }
      Timecop.freeze(@start_of_interval + interval){ sensor.event(123) }

      Timecop.freeze(@start_of_interval + interval + 1) do
        sensor.timeline(2).size.should == 1
      end
      Timecop.freeze(@start_of_interval + interval + 2) do
        sensor.timeline(1).size.should == 0
      end
      Timecop.freeze(@start_of_interval + interval + 1) do
        sensor.timeline(2 + interval).size.should == 2
      end
    end

    describe "SensorData value for an interval" do
      def check_sensor_data(sensor, value)
        data = sensor.timeline(2).first
        data.value.should == value
        data.start_time.to_i.should == @interval_id
      end

      it "should contain summarized value stored by data_key for reduced intervals" do
        Timecop.freeze(@start_of_interval){ sensor.event(123) }
        sensor.reduce(@interval_id)
        Timecop.freeze(@start_of_interval + 1){
          check_sensor_data(sensor, redis.get(sensor.data_key(@interval_id)))
        }
      end

      it "should contain summarized value based on raw data for intervals not yet reduced" do
        Timecop.freeze(@start_of_interval){ sensor.event(123) }
        Timecop.freeze(@start_of_interval + 1){
          check_sensor_data(sensor, sensor.summarize(@raw_data_key))
        }
      end

      it "should contain nil for intervals without any data" do
        Timecop.freeze(@start_of_interval + 1) {
          check_sensor_data(sensor, nil)
        }
      end
    end
  end

  describe "#cleanup" do
    it "should remove all sensor data (raw data, reduced data, annotations) from redis" do
      Timecop.freeze(@start_of_interval){ sensor.event(123) }
      sensor.reduce(@interval_id)
      Timecop.freeze(@start_of_interval + interval){ sensor.event(123) }
      sensor.annotate("Fooo sensor")

      sensor.cleanup
      redis.keys('*').should be_empty
    end
  end

end
