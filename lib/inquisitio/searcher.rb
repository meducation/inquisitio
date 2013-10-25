require 'excon'
require "deep_clone"

module Inquisitio
  class Searcher

    def self.method_missing(name, *args)
      Searcher.new.send(name, *args)
    end

    attr_reader :params, :results
    def initialize(params = nil)
      @params = params || {
        criteria: [], 
        filters: {}, 
        per: 10,
        page: 1,
        returns: [],
        with: {}
      }

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
          s.params[:criteria] << value
        elsif value.is_a?(Hash)
          value.each do |k,v|
            s.params[:filters][k] ||= []
            s.params[:filters][k] << v
          end
        end
      end
    end

    def per(value)
      clone do |s|
        s.params[:per] = value
      end
    end

    def page(value)
      clone do |s|
        s.params[:page] = value
      end
    end

    def returns(*value)
      clone do |s|
        if value.is_a?(Array)
          value.each {|f| s.params[:returns] << f}
        else
          s.params[:returns] << value
        end
      end
    end

    def with(value)
      clone do |s|
        s.params[:with].merge!(value)
      end
    end

    private

    def search_url
      @search_url ||= SearchUrlBuilder.build(
        query: params[:criteria], 
        filters: params[:filters], 
        arguments: params[:with].merge({
          size: params[:per], 
          offset: params[:per] * params[:page]
        }), 
        return_fields: params[:returns]
      )
    end

    def clone
      Searcher.new(DeepClone.clone(params)) do |s|
        yield(s) if block_given?
      end
    end
  end
end
