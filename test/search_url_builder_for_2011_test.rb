require File.expand_path('../test_helper', __FILE__)

module Inquisitio
  class SearchUrlBuilderFor2011Test < Minitest::Test
    def setup
      super
      @search_endpoint = 'http://my.search-endpoint.com'
      Inquisitio.config.search_endpoint = @search_endpoint
      Inquisitio.config.default_search_size = '10'
    end

    def test_create_correct_search_url_with_single_criteria_query
      url = SearchUrlBuilder.build(query: ['Star Wars'])
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?q=Star+Wars&size=10'
      assert_equal expected_url, url
    end

    def test_create_correct_search_url_with_ampersand
      url = SearchUrlBuilder.build(query: ['Star&Wars'])
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?q=Star%26Wars&size=10'
      assert_equal expected_url, url
    end

    def test_create_correct_search_url_with_multiple_criteria_should_create_boolean_query
      url = SearchUrlBuilder.build(query: ['Star Wars', 'Episode One'])
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?bq=%28and+%28or+%27Star+Wars%27+%27Episode+One%27%29%29&size=10'
      assert_equal expected_url, url
    end

    def test_create_correct_search_url_with_multiple_criteria_with_ampersand
      url = SearchUrlBuilder.build(query: ['Star&Wars', 'Episode One'])
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?bq=%28and+%28or+%27Star%26Wars%27+%27Episode+One%27%29%29&size=10'
      assert_equal expected_url, url
    end


    def test_create_correct_search_url_including_return_fields
      url = SearchUrlBuilder.build(query: ['Star Wars'], return_fields: [ 'title', 'year', '%' ] )
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?q=Star+Wars&return-fields=title%2Cyear%2C%25&size=10'
      assert_equal expected_url, url
    end

    def test_create_boolean_query_search_url_with_only_filters
      url = SearchUrlBuilder.build(filters: {title: 'Star Wars'})
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?bq=%28and+title%3A%27Star+Wars%27%29&size=10'
      assert_equal expected_url, url
    end

    def test_create_boolean_query_search_url_with_query_and_filters
      url = SearchUrlBuilder.build(query: ['Star Wars'], filters: {genre: 'Animation'})
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?bq=%28and+%27Star+Wars%27+genre%3A%27Animation%27%29&size=10'
      assert_equal expected_url, url
    end

    def test_create_boolean_query_search_url_with_query_and_filters_and_return_fields
      url = SearchUrlBuilder.build(query: ['Star Wars'], filters: {genre: 'Animation'}, return_fields: [ 'title', 'year', '%' ])
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?bq=%28and+%27Star+Wars%27+genre%3A%27Animation%27%29&return-fields=title%2Cyear%2C%25&size=10'
      assert_equal expected_url, url
    end

    def test_create_search_url_with_added_arguments
      url = SearchUrlBuilder.build(query: ['Star Wars'], filters: {genre: 'Animation'}, :arguments => { facet: 'genre', 'facet-genre-constraints' => 'Animation', 'facet-genre-top-n' => '5'})
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?bq=%28and+%27Star+Wars%27+genre%3A%27Animation%27%29&facet=genre&facet-genre-constraints=Animation&facet-genre-top-n=5&size=10'
      assert_equal expected_url, url
    end

    def test_create_search_url_with_default_size
      url = SearchUrlBuilder.build(query: ['Star Wars'])
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?q=Star+Wars&size=10'
      assert_equal expected_url, url
    end

    def test_create_search_url_overriding_default_size
      url = SearchUrlBuilder.build(query: ['Star Wars'], :arguments => { size: '200' })
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?q=Star+Wars&size=200'
      assert_equal expected_url, url
    end

    def test_create_search_url_with_start_and_default_size
      url = SearchUrlBuilder.build(query: ['Star Wars'], :arguments => { start: '20' })
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?q=Star+Wars&start=20&size=10'
      assert_equal expected_url, url
    end

    def test_create_search_url_with_start_and_size
      url = SearchUrlBuilder.build(query: ['Star Wars'], :arguments => { start: '2', size: '200' })
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?q=Star+Wars&start=2&size=200'
      assert_equal expected_url, url
    end

    def test_create_correct_search_url_with_sanatised_query_string
      url = SearchUrlBuilder.build(query: ['Star\' Wars'], filters: {genre: 'Anim\'ation'}, :arguments => { facet: 'ge\'nre', 'facet-genr\'e-constraints' => 'Anim\'ation', 'facet-gen\'re-top-n' => '\'5'}, return_fields: [ 't\'itle', 'y\'ear' ])
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?bq=%28and+%27Star+Wars%27+genre%3A%27Animation%27%29&return-fields=title%2Cyear&facet=genre&facet-genre-constraints=Animation&facet-genre-top-n=5&size=10'
      assert_equal expected_url, url
    end

    def test_create_search_url_with_filter_array
      url = SearchUrlBuilder.build(query: ['Star Wars'], filters: {genre: ['Animation', 'Action']})
      expected_url = 'http://my.search-endpoint.com/2011-02-01/search?bq=%28and+%27Star+Wars%27+%28or+genre%3A%27Animation%27+genre%3A%27Action%27%29%29&size=10'
      assert_equal expected_url, url
    end

    def test_throws_exception_when_using_unsupported_filter_value_type
      assert_raises(InquisitioError) do
        SearchUrlBuilder.build(query: ['Star Wars'], filters: {genre: {}})
      end
    end
  end
end
