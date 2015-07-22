require File.expand_path('../test_helper', __FILE__)

module Inquisitio
  class FacetsTest < Minitest::Test
    def setup
      super
      @search_endpoint = 'http://my.search-endpoint.com'
      Inquisitio.config.search_endpoint = @search_endpoint
      @body = {
          'status' => {'rid' => '9d3b24b', 'time-ms' => 3},
          'hits' => {'found' => 1, 'start' => 0, 'hit' => [{'data' => {'id' => ['20'], 'title' => ['Foobar2'], 'type' => ['Module_Dog']}}], },
          'facets' => {
              'genres' => {
                  'buckets' => [
                      {'value' => 'Drama', 'count' => 12},
                      {'value' => 'Romance', 'count' => 9}]
              },
              'rating' => {
                  'buckets' => [
                      {'value' => '6.3', 'count' => 3},
                      {'value' => '6.2', 'count' => 2},
                      {'value' => '7.1', 'count' => 2},
                      {'value' => '7.6', 'count' => 1}]
              },
          }
      }.to_json

      Excon.defaults[:mock] = true
      Excon.stub({}, {body: @body, status: 200})
    end

    def teardown
      super
      Excon.stubs.clear
    end

    def test_should_return_fields
      searcher = Searcher.where('star_wars')
      facets = searcher.result_facets
      assert_equal [:genres, :rating], facets.fields
    end

    def test_should_access_buckets_by_symbols
      searcher = Searcher.where('star_wars')
      facets = searcher.result_facets
      refute_nil facets[:genres]
      refute_nil facets[:rating]
    end

    def test_should_have_bucket_lengths
      searcher = Searcher.where('star_wars')
      facets = searcher.result_facets
      assert_equal 2, facets[:genres][:buckets].length
      assert_equal 4, facets[:rating][:buckets].length
    end

    def test_should_have_bucket_entry_values
      searcher = Searcher.where('star_wars')
      facets = searcher.result_facets
      assert_equal 'Drama', facets[:genres][:buckets].first[:value]
      assert_equal '6.2', facets[:rating][:buckets][1][:value]
    end

    def test_should_have_bucket_entry_counts
      searcher = Searcher.where('star_wars')
      facets = searcher.result_facets
      assert_equal 12, facets[:genres][:buckets].first[:count]
      assert_equal 2, facets[:rating][:buckets][1][:count]
    end

  end
end
