require 'spec_helper'

describe PulseMeter::CommandAggregator::UDP do
  let(:host){'127.0.0.1'}
  let(:port){33333}
  let(:udp_sock){mock(:socket)}
  before do 
    UDPSocket.stub!(:new).and_return(udp_sock)
    udp_sock.stub!(:fcntl).and_return(nil)
    @ca = described_class.new([[host, port]])
  end

  describe "#multi" do
    it "should accumulate redis commands and send them in a bulk" do
      data = [
        ["set", "xxxx", "zzzz"],
        ["set", "yyyy", "zzzz"]
      ].to_json
      udp_sock.should_receive(:send).with(data, 0, host, port).and_return(0)
      @ca.multi do
        @ca.set("xxxx", "zzzz")
        @ca.set("yyyy", "zzzz")
      end
    end

    it "should ignore standard exceptions" do
      udp_sock.should_receive(:send).and_raise(StandardError)
      @ca.multi do
        @ca.set("xxxx", "zzzz")
      end
    end
  end

  describe "any other redis instance method" do
    it "should send data imediately" do
      data = [
        ["set", "xxxx", "zzzz"]
      ].to_json
      udp_sock.should_receive(:send).with(data, 0, host, port).and_return(0)
      @ca.set("xxxx", "zzzz")
    end
  end

end

