require 'excon'

module Inquisitio
  class Searcher

    def self.search(query, return_fields)
      new(query, return_fields).search
    end

    def initialize(query, return_fields)
      raise InquisitioError.new("Query is null") if query.nil?
      raise InquisitioError.new("Return Fields is null") if return_fields.nil?

      @query = URI::encode(query)
      comma_separated_return_fields = ""
      return_fields.each do |field|
        comma_separated_return_fields = "#{comma_separated_return_fields},#{field}"
      end
      comma_separated_return_fields[0] = ''
      @return_fields = URI::encode(comma_separated_return_fields)
    end

    def search
      response = Excon.get(search_url)
      raise InquisitioError.new("Search failed with status code: #{response.status}") unless response.status == 200
      response.body
    end

    private

    def search_url
      "#{Inquisitio.config.search_endpoint}/2011-02-01/search?q=#{@query}&return-fields=#{@return_fields}"
    end
  end
end
