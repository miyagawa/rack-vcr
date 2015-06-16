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
        headers_hash_from_env.merge(content_field_hash)
      end

      def headers_hash_from_env
        fields = @req.env.select {|k, v| k.start_with? 'HTTP_' }
                 .collect { |k, v| [normalize_header_field(k), v] }
        Hash[fields]
      end

      def content_field_hash
        { "Content-Type"   => @req.env["CONTENT_TYPE"],
          "Content-Length" => @req.env["CONTENT_LENGTH"] }.reject {|k, v| v.nil? or v == "0" }
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
