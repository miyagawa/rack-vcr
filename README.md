# Rack::VCR

Rack::VCR captures incoming HTTP requests and responses on your Rack application (Rails, Sinatra) and saves them as a VCR fixture in cassettes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-vcr'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-vcr

## Usage

### Rails

TBD

### Sinatra/Rack

To capture HTTP interactions, enable VCR configuration in addition to this middleware, in the spec:

```ruby
require 'rack/test'

VCR.configure do |config|
  config.cassette_library_dir = "vcr_cassettes"
end

describe 'My Web App' do
  include Rack::Test::Methods

  let(:app) {
    Rack::Builder.new do
      use Rack::VCR
      run Sinatra::Application
    end
  }

  it 'runs the request' do
    VCR.use_cassette('hello', record: :all) do
      get "/hello"
    end
    # Now you get vcr_cassettes/hello.yml saved
  end
end
````

## Notes

There's a few similar gems available on Rubygems and GitHub:

* [VCR::Middleware::Rack](https://www.relishapp.com/vcr/vcr/v/1-6-0/docs/middleware/rack) - Records *outgoing* HTTP requests inside a Rack application. Quite opposite to what Rack::VCR gem does.
* [rack-recorder](https://github.com/kodev/rack-recorder) - Essentially the same with Rack::VCR, but is very limited in what it does. It doesn't export the captured transaction in VCR compatible format.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/miyagawa/rack-vcr.

## Author

Tatsuhiko Miyagawa

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

