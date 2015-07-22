require File.expand_path('../test_helper', __FILE__)

module Inquisitio
  class IndexerTest < Minitest::Test
    def setup
      @document_endpoint = 'http://my.document-endpoint.com'
      Inquisitio.config.document_endpoint = @document_endpoint
    #def initialize(type, id, version, fields)
      @documents = [Document.new('add', '12345', 1, {})]
      
      Inquisitio.config.dry_run = false      
    end

    def teardown
      Excon.stubs.clear
    end

    def test_initialization
      indexer = Indexer.new(@documents)
      refute indexer.nil?
    end

    def test_indexer_should_raise_exception_if_documents_nil
      assert_raises(InquisitioError, 'Documents is nil') do
        Indexer.index(nil)
      end
    end

    def test_indexer_should_raise_exception_if_documents_empty
      assert_raises(InquisitioError, 'Documents is empty') do
        Indexer.index([])
      end
    end

    def test_create_correct_index_url
      indexer = Indexer.new(@documents)
      assert_equal 'http://my.document-endpoint.com/2013-01-01/documents/batch', indexer.send(:batch_index_url)
    end

    def test_create_correct_body
      doc1 = mock()
      doc1.expects(:to_sdf).returns('sdf1')
      doc2 = mock()
      doc2.expects(:to_sdf).returns('sdf2')
      doc3 = mock()
      doc3.expects(:to_sdf).returns('sdf3')

      documents = [ doc1, doc2, doc3 ]
      indexer = Indexer.new(documents)
      expected_body = '[sdf1, sdf2, sdf3]'
      assert_equal expected_body, indexer.send(:body)
    end

    def test_index_raises_exception_when_response_not_200
      Excon.defaults[:mock] = true
      Excon.stub({}, {:body => 'Bad Happened', :status => 500})

      indexer = Indexer.new(@documents)

      assert_raises(InquisitioError, 'Indexer failed with status code 500') do
        indexer.index
      end
    end

    def test_index_returns_results
      body = 'Some Body'
      Excon.defaults[:mock] = true
      Excon.stub({}, {:body => body, :status => 200})

      indexer = Indexer.new(@documents)
      response = indexer.index
      assert_equal body, response
    end

    def test_index_does_not_post_when_in_dry_run_mode
      Excon.defaults[:mock] = true
      
      Inquisitio.config.dry_run = true
      
      indexer = Indexer.new(@documents)
      response = indexer.index
      assert response.nil?
    end
  end
end
