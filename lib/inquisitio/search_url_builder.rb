module Inquisitio
  class SearchUrlBuilder

    def self.build(*args)
      new(*args).build
    end

    def initialize(options = {})
      @query_terms = options[:query][:terms]
      @query_named_fields = options[:query][:named_fields] || {}
      @filter_query = options[:filter_query] || {}
      @filter_query_terms = @filter_query[:terms] || []
      @filter_query_named_fields = @filter_query[:named_fields] || {}
      @facets = options[:facets] || {}
      @q_options = options[:q_options] || {}
      @expressions = options[:expressions] || {}
      @return_fields = options[:return_fields] || []
      @size = options[:size] || Inquisitio.config.default_search_size
      @start = options[:start] || 0
      @sort = options[:sort] || {}
      @q_parser = options[:q_parser] || (is_simple?(@query_terms, @query_named_fields) ? nil : :structured)
    end

    def build
      components = []
      components << 'q=' + CGI::escape(build_query(@query_terms, @query_named_fields))
      if !@filter_query_terms.empty? || !@filter_query_named_fields.empty?
        components << 'fq=' + CGI::escape(build_query(@filter_query_terms, @filter_query_named_fields))
      end
      components << "q.parser=#{@q_parser}" if @q_parser
      components << "return=#{CGI::escape(@return_fields.join(',').gsub('\'', ''))}" unless @return_fields.empty?
      # components << arguments
      @facets.each do |field,settings|
        components << "facet.#{field}=#{CGI::escape(settings.to_json)}"
      end
      components << 'q.options=' + CGI::escape(@q_options.to_json) unless @q_options.empty?
      @expressions.each do |name, expression|
        components << "expr.#{name}=" + CGI::escape(expression)
      end
      components << "size=#{@size}"
      components << "start=#{@start}" unless @start == 0 || @start == '0'
      components << 'sort=' + @sort.map { |k, v| "#{k}%20#{v}" }.join(',') unless @sort.empty?
      url_root + components.join('&')
    end

    def is_simple?(terms, named_fields)
      Array(terms).size == 1 && named_fields.empty?
    end

    private

    def build_query(terms, named_fields)
      return terms.first if is_simple?(terms, named_fields)
      query_blocks = []
      query_blocks << '(and' unless terms.empty? || named_fields.empty?

      if terms.size == 1
        query_blocks << "'#{dequote(terms.first)}'"
      elsif terms.size > 1
        query_blocks << "(or #{terms.map { |q| "'#{dequote(q)}'" }.join(' ')})"
      end

      return query_blocks.join(' ') if named_fields.empty?

      query_blocks << '(and' if named_fields.size > 1
      query_blocks += named_fields.map do |key, value|
        raise InquisitioError.new('Named field values must be strings or arrays.') unless value.is_a?(String) || value.is_a?(Array)
        block = "#{dequote(key)}:'#{dequote(value)}'" if value.is_a?(String)
        block = "#{dequote(key)}:'#{dequote(value.first)}'" if value.is_a?(Array) && value.size == 1
        block = "(or #{value.map { |v| "#{dequote(key)}:'#{dequote(v)}'" }.join(' ')})" if value.is_a?(Array) && value.size > 1
        block
      end
      query_blocks << ')' if named_fields.size > 1

      query_blocks << ')' unless terms.empty? || named_fields.empty?
      query_blocks.join(' ')
    end

    def dequote(value)
      value.to_s.gsub('\'', '')
    end

    def url_root
      "#{Inquisitio.config.search_endpoint}/#{Inquisitio.config.api_version}/search?"
    end

  end
end
