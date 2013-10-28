require 'excon'
require "deep_clone"

module Inquisitio
  class Searcher

    def self.method_missing(name, *args)
      Searcher.new.send(name, *args)
    end

    attr_reader :params
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
      results
    end

    def ids
      @ids ||= map{|r|r['med_id']}
    end

    def records
      @records ||= begin
        klasses = {}
        map do |result|
          klass = result['med_type']
          klasses[klass] ||= []
          klasses[klass] << result['med_id']
        end

        klasses.map {|klass, ids|
          klass.constantize.where(id: ids)
        }.flatten
      end
    end

    def where(value)
      clone do |s|
        if value.is_a?(Array)
          s.params[:criteria] += value
        elsif value.is_a?(Hash)
          value.each do |k,v|
            s.params[:filters][k] ||= []
            if v.is_a?(Array)
              s.params[:filters][k] = v
            else
              s.params[:filters][k] << v
            end
          end
        else
          s.params[:criteria] << value
        end
      end
    end

    def per(value)
      clone do |s|
        s.params[:per] = value.to_i
      end
    end

    def page(value)
      clone do |s|
        s.params[:page] = value.to_i
      end
    end

    def returns(*value)
      clone do |s|
        if value.is_a?(Array)
          s.params[:returns] += value
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

    # Proxy everything to the results so that this this class
    # transparently acts as an Array.
    def method_missing(name, *args, &block)
      results.to_a.send(name, *args, &block)
    end

    private

    def results
      if @results.nil?
        response = Excon.get(search_url)
        raise InquisitioError.new("Search failed with status code: #{response.status} Message #{response.body}") unless response.status == 200
        @results = JSON.parse(response.body)["hits"]["hit"]
      end
      @results
    end

    def search_url
      @search_url ||= begin
        return_fields = params[:returns].empty?? [:med_type, :med_id] : params[:returns]

        SearchUrlBuilder.build(
          query: params[:criteria],
          filters: params[:filters],
          arguments: params[:with].merge({
            size: params[:per],
            start: params[:per] * params[:page]
          }),
          return_fields: return_fields
        )
      end
    end

    def clone
      Searcher.new(DeepClone.clone(params)) do |s|
        yield(s) if block_given?
      end
    end
  end
end
