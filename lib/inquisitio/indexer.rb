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
      Inquisitio.config.logger.info "Indexer posting to #{batch_index_url}"
      if Inquisitio.config.dry_run
        Inquisitio.config.logger.info "Skipping POST as running in dry-run mode"
      else
        post_to_endpoint
      end
    end

    private

    def body
      @body ||= "[#{@documents.map(&:to_SDF).join(", ")}]"
    end

    def batch_index_url
      "#{Inquisitio.config.document_endpoint}/#{Inquisitio.config.api_version}/documents/batch"
    end
      
    def post_to_endpoint
      response = Excon.post(batch_index_url,
                           :body => body,
                           :headers => {"Content-Type" =>"application/json"})
      Inquisitio.config.logger.info "Response - status: #{response.status}"
      raise InquisitioError.new("Index failed with status code: #{response.status} Message: #{response.body}") unless response.status == 200
      response.body
    end    
    
  end
end
