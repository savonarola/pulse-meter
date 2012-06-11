require "spec_helper"

describe PulseMeter::Sensor::Remote do

  def bind(host, port)
    @socket = UDPSocket.new
    @socket.bind(host, port)
  end

  def get_data
    data, _ = @socket.recvfrom(65000)
    @socket.close
    data
  end

  let(:host){'localhost'}
  let(:port){56789}
  let(:sensor){described_class.new(:some_remote_sensor, host: host, port: port)}

  describe "#new" do
    it "should raise exception if sensor name is bad" do
      expect{described_class.new("aa bb")}.to raise_exception(PulseMeter::BadSensorName)
    end

    it "should raise PulseMeter::Remote::ConnectionError if remote host is invalid" do
      expect{described_class.new("xxx", host: "bad host")}.to raise_exception(PulseMeter::Remote::ConnectionError)
    end

    it "should raise PulseMeter::Remote::ConnectionError if remote port is invalid" do
      expect{described_class.new("xxx", port: -123)}.to raise_exception(PulseMeter::Remote::ConnectionError)
      expect{described_class.new("xxx", port: 'bad port')}.to raise_exception(PulseMeter::Remote::ConnectionError)
    end
  end

  describe "#event" do
    it "should send event data to remote host and port" do
      bind(host, port)
      sensor.event(123)
      get_data.should_not be_empty
    end

    it "should send event data in JSON format" do
      bind(host, port)
      sensor.event(123)
      expect{JSON.parse(get_data)}.not_to raise_exception
    end

    it "should use sensor name as a single key and sent data as its value" do
      bind(host, port)
      sensor.event(123)
      JSON.parse(get_data).should == {sensor.name => 123}
    end

    it "should raise MessageTooLarge if message is too long" do
      expect{ sensor.event("123" * 100000) }.to raise_exception(PulseMeter::Remote::MessageTooLarge)
    end
  end

  describe "#events" do
    it "should send event data to remote host and port" do
      bind(host, port)
      sensor.events(a: 1, b: 2)
      get_data.should_not be_empty
    end

    it "should send event data in JSON format" do
      bind(host, port)
      sensor.events(a: 1, b: 2)
      expect{JSON.parse(get_data)}.not_to raise_exception
    end

    it "should use sensor name as a single key and sent data as its value" do
      bind(host, port)
      sensor.events(a: 1, b: 2)
      JSON.parse(get_data).should == {"a" => 1, "b" => 2}
    end

    it "should raise ArgumentError if argument is not a hash" do
      expect{ sensor.events(1213) }.to raise_exception(ArgumentError)
    end

    it "should raise MessageTooLarge if message is too long" do
      expect{ sensor.events(a: "x" * 100000) }.to raise_exception(PulseMeter::Remote::MessageTooLarge)
    end
  end

end