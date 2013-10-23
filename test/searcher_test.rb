require File.expand_path('../test_helper', __FILE__)

module Inquisitio
  class SearcherTest < Minitest::Test
    def setup
      super
      @search_endpoint = 'http://my.search-endpoint.com'
      Inquisitio.config.search_endpoint = @search_endpoint
    end

    def teardown
      super
      Excon.stubs.clear
    end

    def test_initialization_with_string
      filters = { :genre => [ 'Animation' ] }
      return_fields = [ 'title' ]
      searcher = Searcher.new('Star Wars', filters.merge({return_fields: return_fields}))
      assert_equal 'Star Wars', searcher.instance_variable_get("@query")
      assert_equal filters, searcher.instance_variable_get("@filters")
      assert_equal return_fields, searcher.instance_variable_get("@return_fields")
    end

    def test_initialization_with_hash
      filters = { :genre => [ 'Animation' ] }
      return_fields = [ 'title' ]
      searcher = Searcher.new(filters.merge({return_fields: return_fields}))
      assert_equal nil, searcher.instance_variable_get("@query")
      assert_equal filters, searcher.instance_variable_get("@filters")
      assert_equal return_fields, searcher.instance_variable_get("@return_fields")
    end

    def test_searcher_should_raise_exception_if_query_null
      assert_raises(InquisitioError, "Query is nil") do
        Searcher.search(nil)
      end
    end

    def test_create_correct_search_url_without_return_fields
      searcher = Searcher.new('Star Wars')
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?q=Star%20Wars'
      assert_equal expected_url, searcher.send(:search_url)
    end

    def test_create_correct_search_url_including_return_fields
      searcher = Searcher.new('Star Wars', { :return_fields => [ 'title', 'year', '%' ] } )
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?q=Star%20Wars&return-fields=title,year,%25'
      assert_equal expected_url, searcher.send(:search_url)
    end

    def test_search_raises_exception_when_response_not_200
      Excon.defaults[:mock] = true
      Excon.stub({}, {:body => 'Bad Happened', :status => 500})

      searcher = Searcher.new('Star Wars')

      assert_raises(InquisitioError, "Search failed with status code 500") do
        searcher.search
      end
    end

    def test_search_returns_results
      body = 'Some Body'
      Excon.defaults[:mock] = true
      Excon.stub({}, {:body => body, :status => 200})

      searcher = Searcher.new('Star Wars', { :return_fields => [ 'title', 'year', '%' ] } )
      response = searcher.search
      assert_equal body, response
    end

    def test_create_boolean_query_search_url_with_only_filters
      searcher = Searcher.new(title: 'Star Wars')
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?bq=(and%20title:\'Star%20Wars\')'
      assert_equal expected_url, searcher.send(:search_url)
    end

    def test_create_boolean_query_search_url_with_query_and_filters
      searcher = Searcher.new('Star Wars', genre: 'Animation')
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?bq=(and%20\'Star%20Wars\'%20genre:\'Animation\')'
      assert_equal expected_url, searcher.send(:search_url)
    end

    def test_create_boolean_query_search_url_with_query_and_filters_and_return_fields
      searcher = Searcher.new('Star Wars', {genre: 'Animation', :return_fields => [ 'title', 'year', '%' ] } )
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?bq=(and%20\'Star%20Wars\'%20genre:\'Animation\')&return-fields=title,year,%25'
      assert_equal expected_url, searcher.send(:search_url)
    end

    def test_create_search_url_with_added_arguments
      searcher = Searcher.new('Star Wars', {genre: 'Animation', :arguments => { facet: 'genre', 'facet-genre-constraints' => 'Animation', 'facet-genre-top-n' => '5'} } )
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?bq=(and%20\'Star%20Wars\'%20genre:\'Animation\')&facet=genre&facet-genre-constraints=Animation&facet-genre-top-n=5'
      assert_equal expected_url, searcher.send(:search_url)
    end
  end
end
