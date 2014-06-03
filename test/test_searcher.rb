require File.expand_path('../test_helper', __FILE__)

module Inquisitio

  class Elephant
    attr_accessor :id, :name
    def initialize(_id, _name)
      @id, @name = _id, _name
    end
  end

  class Giraffe
    attr_accessor :id, :name
    def initialize(_id, _name)
      @id, @name = _id, _name
    end
  end

  class TestSearcher < Minitest::Test
    def setup
      super
      @search_endpoint = 'http://my.search-endpoint.com'
      Inquisitio.config.search_endpoint = @search_endpoint
      Inquisitio.config.api_version = nil
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

    def test_where_sets_variable
      criteria = 'Star Wars'
      searcher = Searcher.where(criteria)
      assert_equal [criteria], searcher.params[:criteria]
    end

    def test_where_sets_variable_with_an_array
      criteria = ['Star', 'Wars']
      searcher = Searcher.where(criteria)
      assert_equal criteria, searcher.params[:criteria]
    end

    def test_where_doesnt_mutate_searcher
      initial_criteria = 'star wars'
      searcher = Searcher.where(initial_criteria)
      searcher.where('Return of the Jedi')
      assert_equal [initial_criteria], searcher.params[:criteria]
    end

    def test_where_returns_a_new_searcher
      searcher1 = Searcher.where('star wars')
      searcher2 = searcher1.where('star wars')
      refute_same searcher1, searcher2
    end

    def test_where_sets_filters
      filters = {genre: 'Animation'}
      searcher = Searcher.where(filters)
      assert_equal({genre: ['Animation']}, searcher.params[:filters])
    end

    def test_where_merges_filters
      filters1 = {genre: 'Animation'}
      filters2 = {foobar: 'Cat'}
      searcher = Searcher.where(filters1).where(filters2)
      assert_equal({genre: ['Animation'], foobar: ['Cat']}, searcher.params[:filters])
    end

    def test_where_merges_filters_with_same_key
      filters1 = {genre: 'Animation'}
      filters2 = {genre: 'Action'}
      searcher = Searcher.where(filters1).where(filters2)
      assert_equal({genre: ["Animation", "Action"]}, searcher.params[:filters])
    end

    def test_where_gets_correct_url
      searcher = Searcher.where('Star Wars')
      assert searcher.send(:search_url).include? "q=Star%20Wars"
    end

    def test_where_gets_correct_url_with_filters_for_2011
      searcher = Searcher.where(title: 'Star Wars')
      assert searcher.send(:search_url).include? "bq=(and%20(or%20title:'Star%20Wars'))"
    end

    def test_where_gets_correct_url_with_filters_for_2013
      Inquisitio.config.api_version = '2013-01-01'
      searcher = Searcher.where(title: 'Star Wars')
      assert searcher.send(:search_url).include? "q=(and%20(or%20title:'Star%20Wars'))&q.parser=structured"
    end

    def test_where_works_with_array_in_a_hash
      criteria = {thing: ['foo', 'bar']}
      searcher = Searcher.where(criteria)
      assert_equal criteria, searcher.params[:filters]
    end

    def test_where_works_with_string_and_array
      str_criteria = 'Star Wars'
      hash_criteria = {thing: ['foo', 'bar']}
      searcher = Searcher.where(str_criteria).where(hash_criteria)
      assert_equal hash_criteria, searcher.params[:filters]
      assert_equal [str_criteria], searcher.params[:criteria]
    end

    def test_per_doesnt_mutate_searcher
      searcher = Searcher.per(10)
      searcher.per(15)
      assert_equal 10, searcher.params[:per]
    end

    def test_per_returns_a_new_searcher
      searcher1 = Searcher.where('star wars')
      searcher2 = searcher1.where('star wars')
      refute_same searcher1, searcher2
    end

    def test_per_sets_variable
      searcher = Searcher.per(15)
      assert_equal 15, searcher.params[:per]
    end

    def test_per_parses_a_string
      searcher = Searcher.per("15")
      assert_equal 15, searcher.params[:per]
    end

    def test_per_gets_correct_url
      searcher = Searcher.per(15)
      assert searcher.send(:search_url).include? "&size=15"
    end

    def test_page_doesnt_mutate_searcher
      searcher = Searcher.page(1)
      searcher.page(2)
      assert_equal 1, searcher.params[:page]
    end

    def test_page_returns_a_new_searcher
      searcher1 = Searcher.page(1)
      searcher2 = searcher1.page(2)
      refute_same searcher1, searcher2
    end

    def test_page_sets_variable
      searcher = Searcher.page(3)
      assert_equal 3, searcher.params[:page]
    end

    def test_page_parses_a_string
      searcher = Searcher.page("15")
      assert_equal 15, searcher.params[:page]
    end

    def test_page_gets_correct_url
      searcher = Searcher.page(3).per(15)
      assert searcher.send(:search_url).include? '&start=30'
    end

    def test_that_starts_at_zero
      searcher = Searcher.where("foo")
      refute searcher.send(:search_url).include? '&start='
    end

    def test_returns_doesnt_mutate_searcher
      searcher = Searcher.returns(:foobar)
      searcher.returns(:dogcat)
      assert_equal [:foobar], searcher.params[:returns]
    end

    def test_returns_returns_a_new_searcher
      searcher1 = Searcher.returns(1)
      searcher2 = searcher1.returns(2)
      refute_same searcher1, searcher2
    end

    def test_returns_sets_variable
      searcher = Searcher.returns('foobar')
      assert searcher.params[:returns].include?('foobar')
    end

    def test_returns_gets_correct_urlns_appends_variable_for_2011
      searcher = Searcher.returns('foobar')
      assert searcher.send(:search_url).include? "&return-fields=foobar"
    end

    def test_returns_gets_correct_urlns_appends_variable_for_2013
      Inquisitio.config.api_version = '2013-01-01'
      searcher = Searcher.returns('foobar')
      assert searcher.send(:search_url).include? "&return=foobar"
    end

    def test_returns_with_array_sets_variable
      searcher = Searcher.returns('dog', 'cat')
      assert_equal ['dog', 'cat'], searcher.params[:returns]
    end

    def test_returns_with_array_gets_correct_url_for_2011
      searcher = Searcher.returns('id', 'foobar')
      assert searcher.send(:search_url).include? "&return-fields=id,foobar"
    end

    def test_returns_with_array_gets_correct_url_for_2013
      Inquisitio.config.api_version = '2013-01-01'
      searcher = Searcher.returns('id', 'foobar')
      assert searcher.send(:search_url).include? "&return=id,foobar"
    end

    def test_returns_appends_variable
      searcher = Searcher.returns('id').returns('foobar')
      assert_equal ['id', 'foobar'], searcher.params[:returns]
    end

    def test_with_saves_variable
      searcher = Searcher.with(foo: 'bar')
      assert_equal({foo:'bar'}, searcher.params[:with])
    end

    def test_with_appends_to_variable
      searcher = Searcher.with(foo: 'bar').with(cat: 'dog')
      assert_equal({foo:'bar', cat:'dog'}, searcher.params[:with])
    end

    def test_with_gets_correct_url
      searcher = Searcher.with(foo: 'bar').with(cat: 'dog')
      assert searcher.send(:search_url).include? "&foo=bar&cat=dog"
    end

    def test_search_calls_search_url_builder
      SearchUrlBuilder.any_instance.expects(build: "http://www.example.com")
      searcher = Searcher.where('Star Wars')
      searcher.search
    end

    def test_search_raises_exception_when_response_not_200
      Excon.stub({}, {:body => 'Bad Happened', :status => 500})

      searcher = Searcher.where('Star Wars')
      searcher.instance_variable_set(:@failed_attempts, 3)

      assert_raises(InquisitioError, "Search failed with status code 500") do
        searcher.search
      end
    end

    def test_search_raises_exception_when_excon_exception_thrown
      Excon.stub({}, lambda { |_| raise Excon::Errors::Timeout})

      searcher = Searcher.where('Star Wars')
      searcher.instance_variable_set(:@failed_attempts, 3)

      assert_raises(InquisitioError) do
        searcher.search
      end
    end

    def test_search_retries_when_failed_attempts_under_limit
      Excon.expects(:get).raises(Excon::Errors::Timeout).times(3)

      searcher = Searcher.where('Star Wars')
      assert_raises(InquisitioError, "Search failed with status code 500") do
        searcher.search
      end
    end

    def test_that_iterating_calls_results
      searcher = Searcher.where("star_wars")
      searcher.expects(results: [])
      searcher.each { }
    end

    def test_that_iterating_calls_each
      searcher = Searcher.where("star_wars")
      searcher.search
      searcher.send(:results).expects(:each)
      searcher.each { }
    end

    def test_that_select_calls_each
      searcher = Searcher.where("star_wars")
      searcher.search
      searcher.send(:results).expects(:select)
      searcher.select { }
    end

    def test_search_should_set_results
      searcher = Searcher.where("star_wars")
      searcher.search
      assert_equal @expected_results, searcher.instance_variable_get("@results")
    end

    def test_search_should_create_a_results_object
      searcher = Searcher.where("star_wars")
      searcher.search
      assert Results, searcher.instance_variable_get("@results").class
    end

    def test_search_only_runs_once
      searcher = Searcher.where("star_wars")
      Excon.expects(:get).returns(mock(status: 200, body: @body)).once
      2.times { searcher.search }
    end

    def test_should_return_type_and_id_by_default_for_2011
      searcher = Searcher.where('Star Wars')
      assert_equal [], searcher.params[:returns]
      assert searcher.send(:search_url).include? "&return-fields=type,id"
    end

    def test_should_not_specify_return_by_default_for_2013
      Inquisitio.config.api_version = '2013-01-01'
      searcher = Searcher.where('Star Wars')
      assert_equal [], searcher.params[:returns]
      refute searcher.send(:search_url).include? "&return="
      refute searcher.send(:search_url).include? "&return-fields="
    end

    def test_should_return_ids
      searcher = Searcher.where('Star Wars')
      assert_equal [1,2,20], searcher.ids
    end

    def test_should_return_records_in_results_order
      expected_1 = Elephant.new(2, 'Sootica')
      expected_2 = Giraffe.new(20, 'Wolf')
      expected_3 = Elephant.new(1, 'Gobbolino')

      Elephant.expects(:where).with(id: ['2','1']).returns([expected_3, expected_1])
      Giraffe.expects(:where).with(id: ['20']).returns([expected_2])

      searcher = Searcher.new
      result = [
          {'data' => {'id' => ['2'],  'type' => ['Inquisitio_Elephant']}},
          {'data' => {'id' => ['20'], 'type' => ['Inquisitio_Giraffe']}},
          {'data' => {'id' => ['1'],  'type' => ['Inquisitio_Elephant']}}
      ]
      searcher.instance_variable_set("@results", result)
      expected_records = [expected_1, expected_2, expected_3]
      actual_records = searcher.records
      assert_equal expected_records, actual_records
    end
  end
end
