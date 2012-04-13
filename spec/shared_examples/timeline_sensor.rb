shared_examples_for "timeline sensor" do
  let(:name){ :some_value_with_history }
  let(:ttl){ 100 }
  let(:raw_data_ttl){ 10 }
  let(:interval){ 5 }
  let(:good_init_values){ {:ttl => ttl, :raw_data_ttl => raw_data_ttl, :interval => interval} }
  let(:sensor){ described_class.new(name, good_init_values) }
  let(:redis){ PulseMeter.redis }

  describe "#event" do
    it "should write events to single current bucket" do
      Timecop.freeze((Time.now.to_i / interval + 1) * interval + 1) do
        expect{
            sensor.event(123)
            sensor.event(124)
            sensor.event(125)
            sensor.event(126)
        }.to change{ redis.keys('*').count }.by(1)
      end
    end
  end
end
