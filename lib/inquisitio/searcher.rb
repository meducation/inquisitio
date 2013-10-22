require 'excon'

module Inquisitio
  class Searcher

    def self.search(query, options = {})
      new(query, options).search
    end

    def initialize(query, options = {})
      raise InquisitioError.new("Query is null") if query.nil?

      @query = URI::encode(query)
      @return_fields = options['return_fields']
    end

    def search
      response = Excon.get(search_url)
      raise InquisitioError.new("Search failed with status code: #{response.status}") unless response.status == 200
      response.body
    end

    private

    def search_url
      "#{Inquisitio.config.search_endpoint}/2011-02-01/search?q=#{@query}#{return_fields_query_string}"
    end

    def return_fields_query_string
      return "" if @return_fields.nil?

      comma_separated_return_fields = ""
      @return_fields.each do |field|
        comma_separated_return_fields = "#{comma_separated_return_fields},#{field}"
      end
      comma_separated_return_fields[0] = ''
      "&return-fields=#{URI::encode(comma_separated_return_fields)}"
    end
  end
end
