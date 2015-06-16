require 'spec_helper'
require 'sinatra'
require 'rack/test'

class MyApp < Sinatra::Application
  get '/hi' do
    "Hello"
  end

  post '/yo' do
    "Yo #{params[:name]}"
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "tmp/cassettes"
end

describe Rack::VCR do
  include Rack::Test::Methods

  vcr = Rack::VCR.new
  around(:each) do |example|
    vcr.record(example.description, &example)
  end

  let(:app) {
    Rack::Builder.new do
      use vcr
      run MyApp
    end
  }

  it 'runs the test' do
    VCR.use_cassette("hi") do
      get '/hi'
      expect(last_response.body).to eq 'Hello'
    end
  end
end
