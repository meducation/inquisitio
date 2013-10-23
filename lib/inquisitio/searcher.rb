require 'excon'

module Inquisitio
  class Searcher

    def self.search(*args)
      searcher = new(*args)
      searcher.search
      searcher
    end

    attr_reader :results
    def initialize(query, filters = {})
      raise InquisitioError.new("Query is null") if query.nil?

      if query.is_a?(String)
        @query = query
        @filters = filters
      else
        @filters = query
      end

      @return_fields = @filters.delete(:return_fields)
      @arguments = @filters.delete(:arguments)
    end

    def search
      response = Excon.get(search_url)
      raise InquisitioError.new("Search failed with status code: #{response.status} Message #{response.body}") unless response.status == 200
      body = response.body
      @results = JSON.parse(body)["hits"]["hit"]
    end

    def ids
      @ids ||= @results.map{|result|result['id']}
    end

    def records
      @records ||= @results.map do |result|
        {result['type'] => result['id']}
      end
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
      "#{Inquisitio.config.search_endpoint}/2011-02-01/search?q=#{URI.encode(@query)}#{return_fields_query_string}#{arguments}"
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
      "#{Inquisitio.config.search_endpoint}/2011-02-01/search?bq=#{boolean_query}#{return_fields_query_string}#{arguments}"
    end

    def return_fields_query_string
      return "" if @return_fields.nil?
      "&return-fields=#{URI::encode(@return_fields.join(','))}"
    end

    def arguments
      return "" if @arguments.nil?
      @arguments.map{|key,value| "&#{key}=#{value}"}.join("")
    end
  end
end
