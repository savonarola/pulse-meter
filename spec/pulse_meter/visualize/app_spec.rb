require 'spec_helper'

describe PulseMeter::Visualize::App do
  include Rack::Test::Methods
  before(:each) do
    @layout = PulseMeter::Visualizer.draw do |l|
      l.title "Foo meters"
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
    last_response.body.should include("Foo meters")
  end

  it "responds to /application.js" do
    get '/js/application.js'
    last_response.should be_ok
  end
end
