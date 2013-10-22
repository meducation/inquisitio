require 'excon'

module Inquisitio
  class Indexer

    def self.index(documents)
      new(documents).index
    end

    def initialize(documents)
      raise InquisitioError.new("Document(s) is null") if documents.nil?
      raise InquisitioError.new("Document(s) is empty") unless documents.any?

      @documents = documents
    end

    def index
      response = Excon.post(batch_index_url,
                           :body => body,
                           :headers => {"Content-Type" =>"application/json"})
      raise InquisitioError.new("Index failed with status code: #{response.status} Message: #{response.body}") unless response.status == 200
      response.body
    end

    private

    def body
      body = @documents.map(&:to_SDF).join(", ")
      "[#{body}]"
    end

    def batch_index_url
      "#{Inquisitio.config.document_endpoint}/2011-02-01/documents/batch"
    end
  end
end
