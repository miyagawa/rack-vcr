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

describe Rack::VCR do
  include Rack::Test::Methods

  before(:each) do
    VCR.configure do |config|
      config.cassette_library_dir = "tmp/cassettes"
      config.hook_into :webmock
    end
  end

  around(:each) do |example|
    example.run
    FileUtils.rm_r VCR.configuration.cassette_library_dir
  end

  let(:app) {
    Rack::Builder.new do
      use Rack::VCR, replay: true
      run MyApp
    end
  }

  let(:cassette) { VCR::Cassette.new(cassette_name) }
  let(:cassette_name) { "test" }

  it 'runs the HTTP request' do
    VCR.use_cassette(cassette_name, record: :all) do
      get '/hi'
      expect(last_response.body).to eq "Hello"
      post '/yo', name: "John"
    end

    expect(cassette.http_interactions.interactions.count).to be(2)
  end

  it 'replays the cassette on Rack' do
    VCR.use_cassette(cassette_name, record: :new_episodes) do
      get '/hi'
    end

    VCR.use_cassette(cassette_name, record: :new_episodes) do
      get '/hi'
      expect(last_response.body).to eq "Hello"
    end
  end

  it 'replays the cassette with webmock' do
    VCR.use_cassette(cassette_name, record: :all) do
      get 'http://ruby-lang.org/hi'
    end

    VCR.use_cassette(cassette_name) do
      res = Net::HTTP.get_response(URI.parse("http://ruby-lang.org/hi"))
      expect(res.body).to eq "Hello"
    end
  end

  context 'with symbol key in env' do
    class SymbolKeyEnv
      def initialize(app)
        @app = app
      end

      def call(env)
        env[:evil] = :evil
        @app.call(env)
      end
    end

    let(:app) {
      Rack::Builder.new do
        use SymbolKeyEnv
        use Rack::VCR, replay: true
        run MyApp
      end
    }

    it 'runs the HTTP request' do
      VCR.use_cassette(cassette_name, record: :all) do
        get '/hi'
        expect(last_response.body).to eq "Hello"
        post '/yo', name: "John"
      end

      expect(cassette.http_interactions.interactions.count).to be(2)
    end
  end

  context 'with Rack::Static' do
    let(:app) {
      root_dir = File.expand_path('../..', __dir__)
      Rack::Builder.new do
        use Rack::VCR, replay: true
        use Rack::Static, urls: ['/LICENSE.txt'], root: root_dir
        run MyApp
      end
    }

    it 'runs the HTTP request' do
      license_text = File.read(File.expand_path('../../LICENSE.txt', __dir__))
      VCR.use_cassette(cassette_name, record: :all) do
        get '/LICENSE.txt'
        expect(last_response.body).to eq license_text
      end

      expect(cassette.http_interactions.interactions.count).to be(1)
    end
  end
end
