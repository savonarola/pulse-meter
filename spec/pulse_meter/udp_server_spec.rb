require 'spec_helper'

describe PulseMeter::UDPServer do
  let(:host){'127.0.0.1'}
  let(:port){33333}
  let(:udp_sock){mock(:socket)}
  let(:redis){PulseMeter.redis}
  before do 
    UDPSocket.should_receive(:new).and_return(udp_sock)
    udp_sock.should_receive(:bind).with(host, port).and_return(nil)
    udp_sock.should_receive("do_not_reverse_lookup=").with(true).and_return(nil)
    @server = described_class.new(host, port)
  end

  describe "#start" do
    let(:data){
      [
        ["set", "xxxx", "zzzz"],
        ["set", "yyyy", "zzzz"]
      ].to_json
    }
    it "should process proper incoming commands" do
      udp_sock.should_receive(:recvfrom).with(described_class::MAX_PACKET).and_return(data)
      @server.start(1)
      redis.get("xxxx").should == "zzzz"
      redis.get("yyyy").should == "zzzz"
    end

    it "should suppress JSON errors" do
      udp_sock.should_receive(:recvfrom).with(described_class::MAX_PACKET).and_return("xxx")
      expect{ @server.start(1) }.not_to raise_exception
    end
  end

end

