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
      @search_url ||= SearchUrlBuilder.build(query: @query, filters: @filters, arguments: @arguments, return_fields: @return_fields)
    end
  end
end
