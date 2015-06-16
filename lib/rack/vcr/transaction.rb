module Rack
  class VCR
    class Transaction
      def self.capture(*args)
        new(*args).record
      end

      def initialize(req, res)
        @req, @res = req, res
      end

      def record
        ::VCR.record_http_interaction(::VCR::HTTPInteraction.new(vcr_request, vcr_response))
      end

      private

      def vcr_request
        ::VCR::Request.new(@req.request_method, @req.url, try_read(@req.body), request_headers)
      end

      def vcr_response
        ::VCR::Response.new(
          ::VCR::ResponseStatus.new(@res.status, nil),
          @res.headers,
          @res.body.join(''),
        )
      end

      def request_headers
        @req.env.select {|k, v| k.start_with? 'HTTP_' }
          .collect { |k, v| [normalize_header_field(k), v] }
      end

      def normalize_header_field(k)
        k.sub(/^HTTP_/, '')
          .split('_').map(&:capitalize).join('-')
      end

      def try_read(body)
        if body
          b = body.read
          body.rewind
          b
        end
      end
    end
  end
end
