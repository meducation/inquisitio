module Inquisitio
  class SearchUrlBuilder

    def self.build(*args)
      new(*args).build
    end

    def initialize(options = {})
      @query         = options[:query]
      @filters       = options[:filters] || {}
      @arguments     = options[:arguments]
      @return_fields = options[:return_fields]
      add_default_size if @arguments.nil? || @arguments[:size].nil?
    end

    def build
      components = [url_root]
      is_simple = @filters.empty? && Array(@query).size == 1
      components << (is_simple ? simple_query : boolean_query)
      components << return_fields_query_string
      components << arguments
      components.join("")
    end

    private
    def simple_query
      "q=#{URI.encode(sanitise(@query.first)).gsub('&', '%26')}"
    end

    def boolean_query

      query_blocks = []

      if Array(@query).empty?
#        query_blocks = []
      elsif @query.size == 1
        query_blocks << "'#{sanitise(@query.first)}'"
      else
        query_blocks << "(or #{@query.map{|q| "'#{sanitise(q)}'"}.join(' ')})"
      end

      query_blocks += @filters.map do |key,value|
        if value.is_a?(String)
          "#{sanitise(key)}:'#{sanitise(value)}'"
        elsif value.is_a?(Array)
          "(or #{value.map {|v| "#{sanitise(key)}:'#{sanitise(v)}'" }.join(" ")})"
        else
          raise InquisitioError.new("Filter values must be strings or arrays.")
        end
      end

      if Inquisitio.config.api_version == '2011-02-01'
        "bq=#{URI.encode("(and #{query_blocks.join(' ')})").gsub('&', '%26')}"
      elsif Inquisitio.config.api_version == '2013-01-01'
        "q=#{URI.encode("(and #{query_blocks.join(' ')})").gsub('&', '%26')}&q.parser=structured"
      end
    end

    def sanitise(value)
      value.to_s.gsub('\'','')
    end

    def return_fields_query_string
      return "" if @return_fields.nil?
      if Inquisitio.config.api_version == '2011-02-01'
        "&return-fields=#{URI::encode(@return_fields.join(',').gsub('\'',''))}"
      elsif Inquisitio.config.api_version == '2013-01-01'
        "&return=#{URI::encode(@return_fields.join(',').gsub('\'',''))}"
      end
    end

    def arguments
      return "" if @arguments.nil?
      @arguments.map{|key,value| "&#{key.to_s.gsub('\'','')}=#{value.to_s.gsub('\'','')}"}.join("")
    end

    def url_root
      "#{Inquisitio.config.search_endpoint}/#{Inquisitio.config.api_version}/search?"
    end

    def add_default_size
      if @arguments.nil?
        @arguments = {}
      end
      if @arguments[:size].nil?
        @arguments = @arguments.merge(:size => Inquisitio.config.default_search_size)
      end
    end
  end
end
