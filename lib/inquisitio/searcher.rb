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
      @failed_attempts = 0

      yield(self) if block_given?
    end

    def search
      results
    end

    def ids
      @ids ||= map{|r|r['data']['id'].first}.flatten.map(&:to_i)
    end

    def records
      @records ||= begin
        klasses = {}
        results.map do |result|
          klass = result['data']['type'].first
          klasses[klass] ||= []
          klasses[klass] << result['data']['id'].first
        end

        klasses.map {|klass, ids|
          klass = klass.gsub("_", "::")
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
      return @results unless @results.nil?

      Inquisitio.config.logger.info("Performing search: #{search_url}")
      response = Excon.get(search_url)
      raise InquisitioError.new("Search failed with status code: #{response.status} Message #{response.body}") unless response.status == 200
      body = JSON.parse(response.body)
      @results = Results.new(body["hits"]["hit"],
                             params[:page],
                             params[:per],
                             body["hits"]["found"])
    rescue => e
      @failed_attempts += 1
      Inquisitio.config.logger.error("Exception Performing search: #{search_url} #{e}")

      if @failed_attempts < Inquisitio.config.max_attempts
        Inquisitio.config.logger.error("Retrying search #{@failed_attempts}/#{Inquisitio.config.max_attempts}")
        results
      else
        raise InquisitioError.new("Exception performing search")
      end
    end

    def search_url
      @search_url ||= begin
        return_fields = params[:returns].empty?? [:type, :id] : params[:returns]

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
