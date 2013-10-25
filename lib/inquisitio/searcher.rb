require 'excon'

module Inquisitio
  class Searcher

    def self.search(*args)
      searcher = new(args)
      searcher.search
      searcher
    end
    
    def self.method_missing(name, *args)
      Searcher.new.send(name, *args)
    end

    attr_reader :results
    def initialize
      @query = '*'
      @per = 10
      @page = 0
      @criteria = []
      @returns = []
      @_with = {}
      yield(self) if block_given?
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
    
    def where(value)
      clone do |s|
        if value.is_a?(String)
          s.criteria << value
        else
          s.filters = value
        end
      end
    end
   
    def per(value)
      clone do |s|
        s.per = value
      end      
    end
   
    def page(value)
      clone do |s|
        s.page = value
      end      
    end
   
    def returns(*value)
      if value.is_a?(Array)
        value.each {|f| @returns << f}        
      else
        @returns << value        
      end
      clone
    end
    
    def with(value)
      clone do |s|
        s._with.merge!(value)
      end    
    end
    
    protected
    
    attr_writer :criteria, :limit, :order, :filters, :per, :_with, :page

    attr_reader :_with, :criteria

    private
    
    def search_url
      @search_url ||= SearchUrlBuilder.build(query: @criteria, filters: @filters, arguments: @_with.merge({size: @per, offset: @per * @page}), return_fields: @returns)
    end
    
    def clone
      Searcher.new do |s|
        s.instance_variable_set(:@filters, @filters)
        s.instance_variable_set(:@per, @per)            
        s.instance_variable_set(:@page, @page)
        s.instance_variable_set(:@criteria, @criteria.flatten)
        s.instance_variable_set(:@returns, @returns)
        s.instance_variable_set(:@_with, @_with)
        yield(s) if block_given?
      end
    end
    
  end
end



=begin
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
=end
