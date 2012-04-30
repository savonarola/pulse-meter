require 'spec_helper'

describe PulseMeter::Visualize::App do
  include Rack::Test::Methods
  before(:each) do
    @layout = PulseMeter::Visualizer.draw do |l|
      l.page "Foo page" do
      end
    end
  end

  def app
    PulseMeter::Visualize::App.new(@layout)
  end
  
  it "responds to /" do
    get '/'
    last_response.should be_ok
  end
end
