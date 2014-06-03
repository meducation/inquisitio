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
      test_search_endpoint = "foobar-123-endpoint"
      Inquisitio.config do |config|
        config.search_endpoint = test_search_endpoint
      end
      assert_equal test_search_endpoint, Inquisitio.config.search_endpoint
    end

    def test_api_version
      assert_equal '2011-02-01', Inquisitio.config.api_version
      Inquisitio.config.api_version = '2013-01-01'
      assert_equal '2013-01-01', Inquisitio.config.api_version
      Inquisitio.config.api_version = nil
      assert_equal '2011-02-01', Inquisitio.config.api_version
      Inquisitio.config.api_version = '2011-02-01'
    end

    def test_search_endpoint
      assert_equal 3, Inquisitio.config.max_attempts
    end

    def test_search_endpoint
      search_endpoint = "test-search-endpoint"
      Inquisitio.config.search_endpoint = search_endpoint
      assert_equal search_endpoint, Inquisitio.config.search_endpoint
    end

    def test_missing_search_endpoint_throws_exception
      assert_raises(InquisitioConfigurationError) do
        Inquisitio.config.search_endpoint
      end
    end

    def test_document_endpoint
      document_endpoint = "test-document-endpoint"
      Inquisitio.config.document_endpoint = document_endpoint
      assert_equal document_endpoint, Inquisitio.config.document_endpoint
    end

    def test_missing_document_endpoint_throws_exception
      assert_raises(InquisitioConfigurationError) do
        Inquisitio.config.document_endpoint
      end
    end

    def test_default_search_size
      default_search_size = "test-default_search_size"
      Inquisitio.config.default_search_size = default_search_size
      assert_equal default_search_size, Inquisitio.config.default_search_size
    end

    def test_missing_default_search_size_throws_exception
      assert_raises(InquisitioConfigurationError) do
        Inquisitio.config.default_search_size
      end
    end

    def test_logger_is_configured_by_default
      assert_kind_of Inquisitio::Logger, Inquisitio.config.logger
    end

    def test_dry_run_disabled_by_default
      refute Inquisitio.config.dry_run
    end
    
    def test_enable_dry_run
      Inquisitio.config.dry_run = true
      assert Inquisitio.config.dry_run
    end
  end
end

