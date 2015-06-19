require "rack/vcr/version"
require "rack/vcr/transaction"
require "vcr"

module Rack
  class VCR
    def initialize(app, options = {})
      @app = app
      @replay = options[:replay]
      @cassette = options[:cassette]
      @record   = options[:record] || :new_episodes
    end

    def call(env)
      if @cassette
        ::VCR.use_cassette(@cassette, record: @record) do
          run_request(env)
        end
      else
        run_request(env)
      end
    end

    def run_request(env)
      req = Rack::Request.new(env)
      transaction = Transaction.new(req)

      if @replay && transaction.can_replay?
        transaction.replay
      else
        status, headers, body = @app.call(env)
        res = Rack::Response.new(body, status, headers)
        transaction.capture(res)
        [status, headers, body]
      end
    end
  end
end
