require 'excon'

module Inquisitio
  class Searcher

    def self.method_missing(name, *args)
      Searcher.new.send(name, *args)
    end

    attr_reader :params, :options

    def initialize(params = nil)
      @params = params || {
          query_terms: [],
          query_named_fields: {},
          filter_query_terms: [],
          filter_query_named_fields: {},
          facets: {},
          per: 10,
          page: 1,
          returns: [],
          sort: {},
          q_options: {},
          expressions: {}
      }

      yield(self) if block_given?
    end

    def search
      results
    end

    def ids
      @ids ||= map { |r| r['data']['id'].first }.flatten.map(&:to_i)
    end

    def records
      return @records unless @records.nil?

      @records = []
      klasses = {}
      results.each do |result|
        klass = result['data']['type'].first
        id = result['data']['id'].first
        klasses[klass] ||= []
        klasses[klass] << id
      end

      objs = klasses.map { |klass_name, ids|
        klass_name = klass_name.gsub('_', '::')
        klass = klass_name.constantize
        klass.where(id: ids)
      }.flatten

      results.each do |result|
        klass_name = result['data']['type'].first
        klass_name = klass_name.gsub('_', '::')
        id = result['data']['id'].first
        record = objs.select { |r|
          r.class.name == klass_name && r.id == id.to_i
        }.first
        @records << record
      end

      return @records
    end

    def where(value)
      clone do |s|
        if value.is_a?(Array)
          s.params[:query_terms] += value
        elsif value.is_a?(Hash)
          value.each do |k, v|
            k = k.to_sym
            s.params[:query_named_fields][k] ||= []
            if v.is_a?(Array)
              s.params[:query_named_fields][k] = v
            else
              s.params[:query_named_fields][k] << v
            end
          end
        else
          s.params[:query_terms] << value
        end
      end
    end

    def filter(value)
      clone do |s|
        if value.nil?
          s.params[:filter_query_terms] = []
          s.params[:filter_query_named_fields] = {}
        elsif value.is_a?(Array)
          s.params[:filter_query_terms] += value
        elsif value.is_a?(Hash)
          value.each do |k, v|
            k = k.to_sym
            s.params[:filter_query_named_fields][k] ||= []
            if v.is_a?(Array)
              s.params[:filter_query_named_fields][k] = v
            else
              s.params[:filter_query_named_fields][k] << v
            end
          end
        else
          s.params[:filter_query_terms] << value
        end
      end
    end

    def options(value)
      clone do |s|
        s.params[:q_options] = value
      end
    end

    def facets(value)
      clone do |s|
        s.params[:facets] = value
      end
    end

    def expressions(value)
      clone do |s|
        s.params[:expressions] = value
      end
    end

    def parser(value)
      clone do |s|
        s.params[:q_parser] = value
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

    def sort(value)
      clone do |s|
        s.params[:sort].merge!(value)
      end
    end

    def result_facets
      @result_facets ||= Facets.new(cloudsearch_body['facets'])
    end

    # Proxy everything to the results so that this this class
    # transparently acts as an Array.
    def method_missing(name, *args, &block)
      results.to_a.send(name, *args, &block)
    end

    private

    def results
      @results ||= begin
        Results.new(cloudsearch_body['hits']['hit'],
                    params[:page],
                    params[:per],
                    cloudsearch_body['hits']['found'],
                    cloudsearch_body['status']['time-ms'])
      end
    end

    def cloudsearch_body
      failed = 0
      @cloudsearch_body ||= begin
        Inquisitio.config.logger.info("Performing search: #{search_url}")
        response = Excon.get(search_url)
        raise InquisitioError.new("Search failed with status code: #{response.status} Message #{response.body}") unless response.status == 200
        JSON.parse(response.body)
      rescue => e
        failed += 1
        Inquisitio.config.logger.error("Exception Performing search: #{search_url} #{e}")

        if failed < Inquisitio.config.max_attempts
          Inquisitio.config.logger.error("Retrying search #{@failed_attempts}/#{Inquisitio.config.max_attempts}")
          retry
        else
          raise InquisitioError.new('Exception performing search')
        end
      end
    end

    def search_url
      @search_url ||= begin
        SearchUrlBuilder.build(
            query: {terms: params[:query_terms], named_fields: params[:query_named_fields]},
            filter_query: {terms: params[:filter_query_terms], named_fields: params[:filter_query_named_fields]},
            facets: params[:facets],
            size: params[:per],
            start: params[:per] * (params[:page] - 1),
            sort: params[:sort],
            q_options: params[:q_options],
            expressions: params[:expressions],
            q_parser: params[:q_parser],
            return_fields: params[:returns]
        )
      end
    end

    def clone
      params_clone = JSON.parse(params.to_json, symbolize_names: true)
      symbolised_params = params_clone.inject({}) do |h, (key, value)|
        h[key.to_sym] = value
        h
      end
      Searcher.new(symbolised_params) do |s|
        yield(s) if block_given?
      end
    end
  end
end
