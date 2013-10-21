require File.expand_path('../test_helper', __FILE__)

module Inquisitio
  class ConfigurationTest < Minitest::Test

    def setup
      Inquisitio.instance_variable_set("@config", nil)
    end

    def test_obtaining_singletion
      refute Inquisitio.config.nil?
    end

    def test_block_syntax
      test_key = "foobar-123-access"
      Inquisitio.config do |config|
        config.access_key = test_key
      end
      assert_equal test_key, Inquisitio.config.access_key
    end

    def test_access_key
      access_key = "test-access-key"
      Inquisitio.config.access_key = access_key
      assert_equal access_key, Inquisitio.config.access_key
    end

    def test_secret_key
      secret_key = "test-secret-key"
      Inquisitio.config.secret_key = secret_key
      assert_equal secret_key, Inquisitio.config.secret_key
    end

    def test_queue_region
      queue_region = "test-queue-region"
      Inquisitio.config.queue_region = queue_region
      assert_equal queue_region, Inquisitio.config.queue_region
    end

    def test_missing_access_key_throws_exception
      assert_raises(InquisitioConfigurationError) do
        Inquisitio.config.access_key
      end
    end

    def test_missing_secret_key_throws_exception
      assert_raises(InquisitioConfigurationError) do
        Inquisitio.config.secret_key
      end
    end

    def test_missing_queue_region_throws_exception
      assert_raises(InquisitioConfigurationError) do
        Inquisitio.config.queue_region
      end
    end
  end
end

