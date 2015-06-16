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

  let(:app) {
    Rack::Builder.new do
      use vcr
      run MyApp
    end
  }

  let(:cassette) { VCR::Cassette.new(cassette_name) }
  let(:cassette_name) { "test" }

  it 'runs the HTTP request' do
    VCR.use_cassette(cassette_name, record: :all) do
      get '/hi'
      expect(last_response.body).to eq 'Hello'
      post '/yo', name: "John"

      expect(cassette.http_interactions.interactions.count).to be(2)
    end
  end
end
