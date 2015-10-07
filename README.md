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

### Capturing in Rails

In `config/initializers/rack_vcr.rb`:

```ruby
if Rails.env.test?
  Rails.configuration.middleware.insert(0, Rack::VCR)
end
```

In `spec/spec_helper.rb`:

```ruby
VCR.configure do |config|
  config.cassette_library_dir = 'doc/cassettes'
end

RSpec.configure do |config|
  config.around(:each, type: :request) do |example|
    host! "yourapp.hostname"
    name = example.full_description.gsub /[^\w\-]/, '_'
    VCR.use_cassette(name, record: :all) do
      example.run
    end
  end
end
```

The above example might not work if you were using RSpec 2.x, in which case you might need to write as follows:

```ruby
RSpec.configure do |config|
  config.around(:each, type: :request) do |ex|
    host! "yourapp.hostname"
    name = example.full_description.gsub /[^\w\-]/, '_'
    VCR.use_cassette(name, record: :all) do
      ex.run
    end
  end
end
```

Read more about the changes around `example` on [RSpec blog post](http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/).

### Capturing in Sinatra/Rack

In `spec/spec_helper.rb`:


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
```

### Replaying

Rack::VCR also supports *replaying* recorded VCR cassettes. It means you can record the HTTP interactions with the real app (on CI), then use the cassette to run a fake/mock API server using Rack::VCR!

To replay cassettes, enable Rack::VCR with `:replay` option in `config.ru` or its equivalent.

```ruby
VCR.configure do |config|
  config.cassette_library_dir = "/path/to/cassettes"
end

Rack::Builder.new do
  use Rack::VCR, replay: true,
    cassette: "test", record: :new_episodes
  run MyApp
end
```

With the above setting, Rack::VCR will try to locate the cassette named "test" to replay if the request matches with what's recorded, and fall through to the original application if it's not there. It also records the result to the cassette for further requests with the `:record` option set to `:new_episodes`.

You can set `:record` option to `:none` for example, to only serve what's already recorded in the cassette. The default value for `:record` option is `:new_episodes`.

To customize the cassette name in runtime, you can write a custom piece of Rack middleware around Rack::VCR to wrap the application in `VCR.use_cassette` with its own `:record` option.

```ruby
class CassetteLocator
  def initialize(app)
    @app = app
  end
  
  def call(env)
    cassette = ... # determine cassette from env
    VCR.use_cassette(cassette, record: :none) do
      @app.call(env)
    end
  end
end

Rack::Builder.new do 
  use CassetteLocator
  use Rack::VCR, replay: true
  run MyApp
end
```


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

