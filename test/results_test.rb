require File.expand_path('../test_helper', __FILE__)

module Inquisitio
  class ResultsTest < Minitest::Test
    def setup
      super
      @search_endpoint = 'http://my.search-endpoint.com'
      Inquisitio.config.search_endpoint = @search_endpoint
      @result_1 = {'data' => {'id' => ['1'], 'title' => ["Foobar"], 'type' => ["Cat"]}}
      @result_2 = {'data' => {'id' => ['2'], 'title' => ["Foobar"], 'type' => ["Cat"]}}
      @result_3 = {'data' => {'id' => ['20'], 'title' => ["Foobar2"], 'type' => ["Module_Dog"]}}
      @expected_results = [@result_1, @result_2, @result_3]
      @start = 5
      @found = 8

      @body = <<-EOS
      {"rank":"-text_relevance","match-expr":"(label 'star wars')","hits":{"found":#{@found},"start":#{@start},"hit":#{@expected_results.to_json}},"info":{"rid":"9d3b24b0e3399866dd8d376a7b1e0f6e930d55830b33a474bfac11146e9ca1b3b8adf0141a93ecee","time-ms":3,"cpu-time-ms":0}}
      EOS

      Excon.defaults[:mock] = true
      Excon.stub({}, {body: @body, status: 200})
    end

    def teardown
      super
      Excon.stubs.clear
    end

    def test_should_return_total_count
      searcher = Searcher.where("star_wars")
      searcher.search
      assert_equal @found, searcher.total_entries
    end

    def test_total_entries_should_proxy
      searcher = Searcher.where("star_wars")
      searcher.search
      assert_equal @found, searcher.total_count
    end

    def test_should_return_results_per_page
      per = 9
      searcher = Searcher.per(per)
      searcher.search
      assert_equal per, searcher.results_per_page
    end

    def test_should_return_limit_value
      per = 9
      searcher = Searcher.per(per)
      searcher.search
      assert_equal per, searcher.limit_value
    end

    def test_should_return_current_page
      page = 7
      searcher = Searcher.page(7)
      searcher.search
      assert_equal page, searcher.current_page
    end

    def test_should_return_total_pages_with_less
      per = 10
      searcher = Searcher.per(per)
      searcher.search
      assert_equal 1, searcher.total_pages
    end

    def test_should_return_total_pages_with_equal
      per = 8
      searcher = Searcher.per(per)
      searcher.search
      assert_equal 1, searcher.total_pages
    end

    def test_should_return_total_pages_with_more
      per = 3
      searcher = Searcher.per(per)
      searcher.search
      assert_equal 3, searcher.total_pages
    end

    def test_nums_pages_should_proxy
      per = 3
      searcher = Searcher.per(per)
      searcher.search
      assert_equal 3, searcher.num_pages
    end

    def test_last_page_before
      results = Inquisitio::Results.new([], 1, nil, nil)
      results.expects(total_pages: 2)
      refute results.last_page?
    end

    def test_last_page_equal
      results = Inquisitio::Results.new([], 2, nil, nil)
      results.expects(total_pages: 2)
      assert results.last_page?
    end
  end
end
