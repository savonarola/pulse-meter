require 'spec_helper'

describe PulseMeter::Visualize::App do
  include Rack::Test::Methods

  def app
    PulseMeter::Visualize::App
  end
  
  it "responds to /" do
    get '/'
    last_response.should be_ok
  end
end
