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
  end
end

