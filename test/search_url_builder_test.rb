require File.expand_path('../test_helper', __FILE__)

module Inquisitio
  class SearchUrlBuilderTest < Minitest::Test
    def setup
      super
      @search_endpoint = 'http://my.search-endpoint.com'
      Inquisitio.config.api_version = '2013-01-01'
      Inquisitio.config.search_endpoint = @search_endpoint
      Inquisitio.config.default_search_size = '10'
    end

    def test_uses_endpoint
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars']})
      assert (/^#{@search_endpoint}\/2013-01-01\/search(\?|$)/ =~ url), "Should start with endpoint: #{url}"
    end

    def test_create_correct_search_url_with_single_criteria_query
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars']})
      assert /(&|\?)q=Star\+Wars(&|$)/ =~ url
    end

    def test_create_correct_search_url_with_single_criteria_query_and_single_filter_criteria
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars']}, filter_query: {terms: ['A New Hope']})
      assert /(&|\?)q=Star\+Wars(&|$)/ =~ url, "should have query in url: #{url}"
      assert /(&|\?)fq=A\+New\+Hope(&|$)/ =~ url, "should have filter query in url: #{url}"
    end

    def test_create_correct_search_url_with_ampersand
      url = SearchUrlBuilder.build(query: {terms: ['Star&Wars']})
      expected_url = 'http://my.search-endpoint.com/2013-01-01/search?q=Star%26Wars&size=10'
      assert_equal expected_url, url
    end

    def test_create_correct_search_url_with_multiple_criteria_should_use_structured_parser
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars', 'Episode One']})
      expected_url = 'http://my.search-endpoint.com/2013-01-01/search?q=%28or+%27Star+Wars%27+%27Episode+One%27%29&q.parser=structured&size=10'
      assert_equal expected_url, url
    end

    def test_create_correct_search_url_with_multiple_criteria_with_ampersand
      url = SearchUrlBuilder.build(query: {terms: ['Star&Wars', 'Episode One']})
      expected_url = 'http://my.search-endpoint.com/2013-01-01/search?q=%28or+%27Star%26Wars%27+%27Episode+One%27%29&q.parser=structured&size=10'
      assert_equal expected_url, url
    end

    def test_create_correct_search_url_including_return_fields
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars']}, return_fields: %w(title year %))
      expected_url = 'http://my.search-endpoint.com/2013-01-01/search?q=Star+Wars&return=title%2Cyear%2C%25&size=10'
      assert_equal expected_url, url
    end

    def test_create_search_url_with_default_size
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars']})
      expected_url = 'http://my.search-endpoint.com/2013-01-01/search?q=Star+Wars&size=10'
      assert_equal expected_url, url
    end

    def test_create_search_url_overriding_default_size
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars']}, size: '200')
      expected_url = 'http://my.search-endpoint.com/2013-01-01/search?q=Star+Wars&size=200'
      assert_equal expected_url, url
    end

    def test_create_search_url_with_start_and_default_size
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars']}, start: '20')
      assert /(&|\?)start=20(&|$)/ =~ url
      assert /(&|\?)size=10(&|$)/ =~ url
    end

    def test_create_search_url_with_start_and_size
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars']}, start: '2', size: '200')
      assert /(&|\?)start=2(&|$)/ =~ url
      assert /(&|\?)size=200(&|$)/ =~ url
    end

    def test_create_search_url_with_named_fields_array
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars'], named_fields: {genre: %w(Animation Action)}})
      assert /(&|\?)q=%28and\+%27Star\+Wars%27\+%28or\+genre%3A%27Animation%27\+genre%3A%27Action%27%29\+%29(&|$)/ =~ url
      assert /(&|\?)q.parser=structured(&|$)/ =~ url
    end

    def test_create_search_url_with_named_fields_in_filter_query
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars']}, filter_query: {terms: ['A New Hope'], named_fields: {genre: %w(Animation Action)}})
      assert /(&|\?)q=Star\+Wars(&|$)/ =~ url, "should have query in url: #{url}"
      assert /(&|\?)fq=%28and\+%27A\+New\+Hope%27\+%28or\+genre%3A%27Animation%27\+genre%3A%27Action%27%29\+%29(&|$)/ =~ url, "should have filter query in url: #{url}"
    end

    def test_create_search_url_with_multiple_named_fields_in_filter_query
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars']}, filter_query: {terms: [], named_fields: {genre: %w(Animation Action), foo: 'bar'}})
      assert /(&|\?)q=Star\+Wars(&|$)/ =~ url, "should have query in url: #{url}"
      assert_match /(&|\?)fq=%28and\+%28or\+genre%3A%27Animation%27\+genre%3A%27Action%27%29\+foo%3A%27bar%27\+%29(&|$)/, url
    end

    def test_create_search_url_with_query_options
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars']}, q_options: {fields: %w(title^2.0 plot^0.5)})
      expected_url = 'http://my.search-endpoint.com/2013-01-01/search?q=Star+Wars&q.options=%7B%22fields%22%3A%5B%22title%5E2.0%22%2C%22plot%5E0.5%22%5D%7D&size=10'
      assert_equal expected_url, url
    end

    def test_create_search_url_with_query_defaultoperator_option
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars']}, q_options: {defaultOperator: 'or'})
      expected_url = 'http://my.search-endpoint.com/2013-01-01/search?q=Star+Wars&q.options=%7B%22defaultOperator%22%3A%22or%22%7D&size=10'
      assert_equal expected_url, url
    end

    def test_create_search_url_with_expressions
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars']}, expressions: {rank1: 'log10(clicks)*_score', rank2: 'cos( _score)'})
      expected_url = 'http://my.search-endpoint.com/2013-01-01/search?q=Star+Wars&expr.rank1=log10%28clicks%29%2A_score&expr.rank2=cos%28+_score%29&size=10'
      assert_equal expected_url, url
    end

    def test_create_url_with_parser
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars']}, q_parser: :structured)
      expected_url = 'http://my.search-endpoint.com/2013-01-01/search?q=Star+Wars&q.parser=structured&size=10'
      assert_equal expected_url, url
    end

    def test_create_url_with_overridden_parser
      url = SearchUrlBuilder.build(query: {terms: ['Star Wars', 'Star Trek']}, q_parser: :simple)
      expected_url = 'http://my.search-endpoint.com/2013-01-01/search?q=%28or+%27Star+Wars%27+%27Star+Trek%27%29&q.parser=simple&size=10'
      assert_equal expected_url, url
    end

  end
end
