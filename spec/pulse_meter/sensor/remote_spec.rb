require "spec_helper"

describe PulseMeter::Sensor::Remote do

  def data_sent_to(host, port)
    socket = UDPSocket.new
    socket.bind(host, port)
    yield
    data, _ = socket.recvfrom(65000)
    socket.close
    data
  end

  let(:host){'localhost'}
  let(:port){56789}
  let(:sensor){described_class.new(:some_remote_sensor, host: host, port: port)}

  describe "#new" do
    it "should raise exception if sensor name is bad" do
      expect{described_class.new("aa bb")}.to raise_exception(PulseMeter::BadSensorName)
    end
  end

  describe "#event" do
    it "should send event data to remote host and port" do
      data_sent_to(host, port) {
        sensor.event(123)
      }.should_not be_empty
    end

    it "should use sensor name as a single key and sent data as its value" do
      data = data_sent_to(host, port) do
        sensor.event(123)
      end
      JSON.parse(data).should == {sensor.name => 123}
    end

    it "should raise MessageTooLarge if message is too long" do
      expect{ sensor.event("123" * 100000) }.to raise_exception(PulseMeter::Remote::MessageTooLarge)
    end


    it "should raise PulseMeter::Remote::ConnectionError if remote host is invalid" do
      expect{described_class.new("xxx", host: "bad host").event(123)}.to raise_exception(PulseMeter::Remote::ConnectionError)
    end

    it "should raise PulseMeter::Remote::ConnectionError if remote port is invalid" do
      expect{described_class.new("xxx", port: -123).event(123)}.to raise_exception(PulseMeter::Remote::ConnectionError)
      expect{described_class.new("xxx", port: 'bad port').event(123)}.to raise_exception(PulseMeter::Remote::ConnectionError)
    end

  end

  describe "#events" do
    it "should send event data to remote host and port" do
      data_sent_to(host, port) {
        sensor.events(a: 1, b: 2)
      }.should_not be_empty
    end

    it "should use sensor name as a single key and sent data as its value" do
      data = data_sent_to(host, port) do
        sensor.events(a: 1, b: 2)
      end
      JSON.parse(data).should == {"a" => 1, "b" => 2}
    end

    it "should raise ArgumentError if argument is not a hash" do
      expect{ sensor.events(1213) }.to raise_exception(ArgumentError)
    end

    it "should raise MessageTooLarge if message is too long" do
      expect{ sensor.events(a: "x" * 100000) }.to raise_exception(PulseMeter::Remote::MessageTooLarge)
    end

    it "should raise PulseMeter::Remote::ConnectionError if remote host is invalid" do
      expect{described_class.new("xxx", host: "bad host").events(a: 123)}.to raise_exception(PulseMeter::Remote::ConnectionError)
    end

    it "should raise PulseMeter::Remote::ConnectionError if remote port is invalid" do
      expect{described_class.new("xxx", port: -123).events(a: 123)}.to raise_exception(PulseMeter::Remote::ConnectionError)
      expect{described_class.new("xxx", port: 'bad port').events(a: 123)}.to raise_exception(PulseMeter::Remote::ConnectionError)
    end
  end

end