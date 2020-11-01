if ENV['MEASURE_COVERAGE'] == 'true'
  require 'simplecov'
  SimpleCov.start
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rack/vcr'
