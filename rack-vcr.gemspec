# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/vcr/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-vcr"
  spec.version       = Rack::VCR::VERSION
  spec.authors       = ["Tatsuhiko Miyagawa"]
  spec.email         = ["miyagawa@bulknews.net"]

  spec.summary       = %q{Record incoming Rack request as VCR cassettes}
  spec.description   = %q{This Rack middleware records incoming Rack request and responses in a VCR compatible format.}
  spec.homepage      = "https://github.com/miyagawa/rack-vcr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "vcr", ">= 2.9"

  spec.add_development_dependency "bundler", ">= 1.10"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec"

  spec.add_development_dependency "sinatra", "~> 1.4"
  spec.add_development_dependency "rack-test", "~> 0.6"
  spec.add_development_dependency "webmock", "~> 3"
end
