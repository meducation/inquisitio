require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

gem "minitest"
require "minitest/autorun"
require "minitest/pride"
require "minitest/mock"
require "mocha/setup"

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "inquisitio"

class Minitest::Test
  def setup
    Inquisitio.config do |config|
      config.search_endpoint = "test-search-endpoint"

      config.logger.stubs(:debug)
      config.logger.stubs(:error)
    end
  end
end
