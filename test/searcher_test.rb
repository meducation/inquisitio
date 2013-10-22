require File.expand_path('../test_helper', __FILE__)

module Inquisitio
  class SearcherTest < Minitest::Test
    def setup
      @search_endpoint = 'http://my.search-endpoint.com'
    end

    def teardown
      Excon.stubs.clear
    end

    def test_initialization
      searcher = Searcher.new('Star Wars', [ 'title' ])
      refute searcher.nil?
    end

    def test_searcher_should_raise_exception_if_query_null
      assert_raises(InquisitioError, "Query is nil") do
        Searcher.search(nil, [ 'title' ])
      end
    end

    def test_searcher_should_raise_exception_if_return_fields_null
      assert_raises(InquisitioError, "Return Fields is nil") do
        Searcher.search('Star Wars', nil)
      end
    end

    def test_create_correct_search_url
      Inquisitio.config.search_endpoint = @search_endpoint
      searcher = Searcher.new('Star Wars', [ 'title', 'year', '%' ])
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?q=Star%20Wars&return-fields=title,year,%25'
      assert_equal expected_url, searcher.send(:search_url)
    end

    def test_search_raises_exception_when_response_not_200
      Excon.defaults[:mock] = true
      Excon.stub({}, {:body => 'Bad Happened', :status => 500})

      Inquisitio.config.search_endpoint = @search_endpoint
      searcher = Searcher.new('Star Wars', [ 'title', 'year', '%' ])

      assert_raises(InquisitioError, "Search failed with status code 500") do
        searcher.search
      end
    end

    def test_search_returns_results
      body = 'Some Body'
      Excon.defaults[:mock] = true
      Excon.stub({}, {:body => body, :status => 200})

      Inquisitio.config.search_endpoint = @search_endpoint

      searcher = Searcher.new('Star Wars', [ 'title', 'year', '%' ])
      response = searcher.search
      assert_equal body, response
    end
  end
end
