require 'spec_helper'
require 'sinatra'
require 'rack/test'
require 'webmock'

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
  config.hook_into :webmock
end

describe Rack::VCR do
  include Rack::Test::Methods

  around(:each) do |example|
    example.run
    FileUtils.rm_r VCR.configuration.cassette_library_dir
  end

  let(:app) {
    Rack::Builder.new do
      use Rack::VCR
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
    end

    expect(cassette.http_interactions.interactions.count).to be(2)
  end

  it 'replays the cassette' do
    VCR.use_cassette(cassette_name, record: :all) do
      get 'http://ruby-lang.org/hi'
    end

    VCR.use_cassette(cassette_name) do
      res = Net::HTTP.get_response(URI.parse("http://ruby-lang.org/hi"))
      expect(res.body).to eq "Hello"
    end
  end
end
