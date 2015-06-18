require 'spec_helper'
require 'sinatra'
require 'rack/test'

VCR.configure do |config|
  config.cassette_library_dir = "spec/cassettes"
end

describe "Rack::VCR with replay" do
  include Rack::Test::Methods

  context 'with the replay option with no VCR cassette' do
    let(:app) {
      Rack::Builder.new do
        use Rack::VCR, replay: true
        run Sinatra::Application
      end
    }

    it 'does not locate cassette' do
      get '/hi'
      expect(last_response.status).to eq 404
    end
  end
  
  context 'with the replay option with hardcoded VCR cassette' do
    let(:app) {
      Rack::Builder.new do
        use Rack::VCR, replay: true, cassette: "test"
        run Sinatra::Application
      end
    }

    it 'locates the cassette' do
      get '/hi'
      expect(last_response.body).to eq "Hello"
    end
  end

  context 'with the dynamic Rack middleware to find cassette' do
    class CassetteFinder
      def initialize(app)
        @app = app
      end

      def call(env)
        VCR.use_cassette("test", record: :none) do
          @app.call(env)
        end
      end
    end

    let(:app) {
      Rack::Builder.new do
        use CassetteFinder
        use Rack::VCR, replay: true
        run Sinatra::Application
      end
    }

    it 'locates the cassette' do
      get '/hi'
      expect(last_response.body).to eq "Hello"
    end
  end
end
