module Inquisitio
  class SearchUrlBuilder

    def self.build(*args)
      new(*args).build
    end

    def initialize(options = {})
      @query = options[:query]
      @filters = options[:filters] || {}
      @q_options = options[:q_options] || {}
      @expressions = options[:expressions] || {}
      @arguments = options[:arguments] || {}
      @return_fields = options[:return_fields]
      @size = options[:size] || Inquisitio.config.default_search_size
      @start = options[:start] || 0
      @sort = options[:sort] || {}
      @q_parser = options[:q_parser] || (is_simple? ? nil : :structured)
    end

    def build
      components = [url_root]
      components << (is_simple? ? simple_query : boolean_query)
      components << "&q.parser=#{@q_parser}" if @q_parser && Inquisitio.config.api_version == '2013-01-01'
      components << return_fields_query_string
      components << arguments
      components << '&q.options=' + CGI::escape(@q_options.to_json) unless @q_options.empty?
      @expressions.each do |name, expression|
        components << "&expr.#{name}=" + CGI::escape(expression)
      end
      components << "&size=#{@size}" unless @arguments[:size]
      components << "&start=#{@start}" unless @arguments[:start] || @start == 0 || @start == '0'
      components << '&sort=' + @sort.map { |k, v| "#{k}%20#{v}" }.join(',') unless @sort.empty?
      components.join('')
    end

    def is_simple?
      @filters.empty? && Array(@query).size == 1
    end

    private
    def simple_query
      "q=#{CGI::escape(sanitise(@query.first)).gsub('&', '%26')}"
    end

    def boolean_query

      query_blocks = []

      if Array(@query).empty?
#        query_blocks = []
      elsif @query.size == 1
        query_blocks << "'#{sanitise(@query.first)}'"
      else
        query_blocks << "(or #{@query.map { |q| "'#{sanitise(q)}'" }.join(' ')})"
      end

      query_blocks += @filters.map do |key, value|
        if value.is_a?(String)
          "#{sanitise(key)}:'#{sanitise(value)}'"
        elsif value.is_a?(Array)
          "(or #{value.map { |v| "#{sanitise(key)}:'#{sanitise(v)}'" }.join(" ")})"
        else
          raise InquisitioError.new('Filter values must be strings or arrays.')
        end
      end

      if Inquisitio.config.api_version == '2011-02-01'
        "bq=#{CGI::escape("(and #{query_blocks.join(' ')})").gsub('&', '%26')}"
      elsif Inquisitio.config.api_version == '2013-01-01'
        "q=#{CGI::escape("(and #{query_blocks.join(' ')})").gsub('&', '%26')}"
      end
    end

    def sanitise(value)
      value.to_s.gsub('\'', '')
    end

    def return_fields_query_string
      return '' if @return_fields.nil?
      if Inquisitio.config.api_version == '2011-02-01'
        "&return-fields=#{CGI::escape(@return_fields.join(',').gsub('\'', ''))}"
      elsif Inquisitio.config.api_version == '2013-01-01'
        "&return=#{CGI::escape(@return_fields.join(',').gsub('\'', ''))}"
      end
    end

    def arguments
      return '' if @arguments.nil?
      @arguments.map { |key, value| "&#{key.to_s.gsub('\'', '')}=#{value.to_s.gsub('\'', '')}" }.join("")
    end

    def url_root
      "#{Inquisitio.config.search_endpoint}/#{Inquisitio.config.api_version}/search?"
    end

  end
end
