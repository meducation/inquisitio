require File.expand_path('../test_helper', __FILE__)

module Inquisitio
  class SearcherTest < Minitest::Test
    def setup
      super
      @search_endpoint = 'http://my.search-endpoint.com'
      Inquisitio.config.search_endpoint = @search_endpoint
      @expected_result_1 = {'id' => 1, 'title' => "Foobar", 'type' => "cat"}
      @expected_result_2 = {'id' => 2, 'title' => "Foobar2", 'type' => "dog"}
      @expected_results = [@expected_result_1, @expected_result_2]

      body = <<-EOS
      {"rank":"-text_relevance","match-expr":"(label 'star wars')","hits":{"found":2,"start":0,"hit":#{@expected_results.to_json}},"info":{"rid":"9d3b24b0e3399866dd8d376a7b1e0f6e930d55830b33a474bfac11146e9ca1b3b8adf0141a93ecee","time-ms":3,"cpu-time-ms":0}}
      EOS

      Excon.defaults[:mock] = true
      Excon.stub({}, {body: body, status: 200})
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

    def test_where_gets_correct_url_with_filters
      searcher = Searcher.where(title: 'Star Wars')
      assert searcher.send(:search_url).include? "bq=(and%20(or%20title:'Star%20Wars'))"
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

    def test_page_gets_correct_url
      searcher = Searcher.page(3).per(15)
      assert searcher.send(:search_url).include? "&offset=45"
    end

    def test_returns_doesnt_mutate_searcher
      searcher = Searcher.returns(1)
      searcher.returns(2)
      assert_equal [1], searcher.params[:returns]
    end

    def test_returns_returns_a_new_searcher
      searcher1 = Searcher.returns(1)
      searcher2 = searcher1.returns(2)
      refute_same searcher1, searcher2
    end

    def test_returns_sets_variable
      searcher = Searcher.returns('med_id')
      assert_equal ['med_id'], searcher.params[:returns]
    end

    def test_returns_gets_correct_urlns_appends_variable
      searcher = Searcher.returns('med_id')
      assert searcher.send(:search_url).include? "&return-fields=med_id"
    end

    def test_returns_with_array_sets_variable
      searcher = Searcher.returns('med_id', 'foobar')
      assert_equal ['med_id', 'foobar'], searcher.params[:returns]
    end

    def test_returns_with_array_gets_correct_url
      searcher = Searcher.returns('med_id', 'foobar')
      assert searcher.send(:search_url).include? "&return-fields=med_id,foobar"
    end

    def test_returns_appends_variable
      searcher = Searcher.returns('med_id').returns('foobar')
      assert_equal ['med_id', 'foobar'], searcher.params[:returns]
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

      assert_raises(InquisitioError, "Search failed with status code 500") do
        searcher.search
      end
    end

    def test_search_should_set_results
      searcher = Searcher.where("star_wars")
      searcher.search
      assert_equal @expected_results, searcher.instance_variable_get("@results")
    end

=begin
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

    def test_search_should_set_ids
      searcher = Searcher.new('Star Wars', { :return_fields => [ 'title', 'year', '%' ] } )
      searcher.search
      assert_equal @expected_results.map{|r|r['id']}, searcher.ids
    end

    def test_search_should_set_records
      searcher = Searcher.new('Star Wars', { :return_fields => [ 'title', 'year', '%' ] } )
      searcher.search

      # [{"MediaFile" => 1}, {...}]
      records = []
      records << {@expected_result_1['type'] => @expected_result_1['id']}
      records << {@expected_result_2['type'] => @expected_result_2['id']}
      assert_equal records, searcher.records
    end
  end
=end
  end
end
