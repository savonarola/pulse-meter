require 'spec_helper'

describe PulseMeter do
  describe "#send" do
    include_context :dsl
    let(:sensor) { :udp_sensor }
    let(:value) { 1 }

    def packed_size
      PulseMeter::Client::Protocol.pack(sensor, value).size
    end

    context "when adrr not valid" do
      it "should handle error" do
        expect {
          described_class.send(:invalid_udp_sensor, value)
        }.should raise_error(PulseMeter::Client::Error)
      end
    end

    context "when valid socket params" do
      it "should call UDP client for remote sensor" do
        described_class.send(sensor, value).should == packed_size
      end
    end
  end
end
