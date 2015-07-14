require 'excon'

module Inquisitio
  class Searcher

    def self.method_missing(name, *args)
      Searcher.new.send(name, *args)
    end

    attr_reader :params, :options

    def initialize(params = nil)
      @params = params || {
        criteria: [],
        filters: {},
        per: 10,
        page: 1,
        returns: [],
        with: {},
        sort: {},
        q_options: {}
      }
      @failed_attempts = 0

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
          s.params[:criteria] += value
        elsif value.is_a?(Hash)
          value.each do |k, v|
            k = k.to_sym
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

    def options(value)
      clone do |s|
        s.params[:q_options] = value
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

    def sort(value)
      clone do |s|
        s.params[:sort].merge!(value)
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
      time_ms = body['info']['time-ms'] if Inquisitio.config.api_version == '2011-02-01'
      time_ms = body['status']['time-ms'] if Inquisitio.config.api_version == '2013-01-01'
      @results = Results.new(body['hits']['hit'],
        params[:page],
        params[:per],
        body['hits']['found'],
        time_ms)
    rescue => e
      @failed_attempts += 1
      Inquisitio.config.logger.error("Exception Performing search: #{search_url} #{e}")

      if @failed_attempts < Inquisitio.config.max_attempts
        Inquisitio.config.logger.error("Retrying search #{@failed_attempts}/#{Inquisitio.config.max_attempts}")
        results
      else
        raise InquisitioError.new('Exception performing search')
      end
    end

    def search_url
      @search_url ||= begin
        if Inquisitio.config.api_version == '2011-02-01'
          return_fields = params[:returns].empty? ? [:type, :id] : params[:returns]
        elsif Inquisitio.config.api_version == '2013-01-01'
          return_fields = params[:returns].empty? ? nil : params[:returns]
        end

        SearchUrlBuilder.build(
          query: params[:criteria],
          filters: params[:filters],
          arguments: params[:with],
          size: params[:per],
          start: params[:per] * (params[:page] - 1),
          sort: params[:sort],
          q_options: params[:q_options],
          return_fields: return_fields
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
