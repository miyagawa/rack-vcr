module Rack
  class VCR
    class Transaction
      def initialize(req)
        @req = req
      end

      def capture(res)
        @res = res
        ::VCR.record_http_interaction(::VCR::HTTPInteraction.new(vcr_request, vcr_response))
      end

      def can_replay?
        ::VCR.http_interactions.has_interaction_matching?(vcr_request)
      end

      def replay
        to_rack_response(::VCR.http_interactions.response_for(vcr_request))
      end

      private

      def vcr_request
        @vcr_request ||=
          ::VCR::Request.new(@req.request_method, @req.url, try_read(@req.body), request_headers)
      end

      def vcr_response
        ::VCR::Response.new(
          ::VCR::ResponseStatus.new(@res.status, nil),
          @res.headers,
          @res.body.to_enum.to_a.join(''),
        )
      end

      def to_rack_response(res)
        [
          res.status.code,
          Hash[res.headers.map {|k, v| [k, v.join("\n")] }],
          [res.body],
        ]
      end

      def request_headers
        headers_hash_from_env.merge(content_field_hash)
      end

      def headers_hash_from_env
        fields = @req.env
                   .map { |k, v| [k.to_s, v] }
                   .select {|k, v| k.start_with?('HTTP_') }
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
