require 'excon'

module Inquisitio
  class Searcher

    def self.search(*args)
      new(*args).search
    end

    def initialize(query, filters = {})
      raise InquisitioError.new("Query is null") if query.nil?

      if query.is_a?(String)
        @query = query
        @filters = filters
      else
        @filters = query
      end

      @return_fields = @filters.delete(:return_fields)
    end

    def search
      response = Excon.get(search_url)
      raise InquisitioError.new("Search failed with status code: #{response.status} Message #{response.body}") unless response.status == 200
      response.body
    end

    private

    def search_url
      if @filters.empty?
        simple_search_url
      else
        boolean_search_url
      end
    end

    def simple_search_url
      "#{Inquisitio.config.search_endpoint}/2011-02-01/search?q=#{URI.encode(@query)}#{return_fields_query_string}"
    end

    def boolean_search_url
      filters = @filters.map{|key,value| "#{key}:'#{value}'"}
      if @query.nil?
        queries = filters.join(" ")
      else
        queries = ["'#{@query}'"].concat(filters).compact.join(" ")
      end

      query_string = "and #{queries}"
      boolean_query = URI.encode("(#{query_string})")
      "#{Inquisitio.config.search_endpoint}/2011-02-01/search?bq=#{boolean_query}#{return_fields_query_string}"
    end

    def return_fields_query_string
      return "" if @return_fields.nil?
      "&return-fields=#{URI::encode(@return_fields.join(','))}"
    end
  end
end
