require "rack/vcr/version"
require "rack/vcr/transaction"
require "vcr"

module Rack
  class VCR
    def initialize(app)
      @app = app
    end

    def call(env)
      req = Rack::Request.new(env)
      status, headers, body = @app.call(env)
      res = Rack::Response.new(body, status, headers)
      Transaction.capture(req, res)
      [status, headers, body]
    end
  end
end
