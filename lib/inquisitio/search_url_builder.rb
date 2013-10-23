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
    end

    def build
      components = [url_root]
      components << (@filters.empty?? simple_query : boolean_query)
      components << return_fields_query_string
      components << arguments
      components.join("")
    end

    private
    def simple_query
      "q=#{URI.encode(@query)}"
    end

    def boolean_query
      filters = @filters.map{|key,value| "#{key}:'#{value}'"}
      queries = filters.join(" ")
      queries = "'#{@query}' #{queries}" if @query
      "bq=#{URI.encode("(and #{queries})")}"
    end

    def return_fields_query_string
      return "" if @return_fields.nil?
      "&return-fields=#{URI::encode(@return_fields.join(','))}"
    end

    def arguments
      return "" if @arguments.nil?
      @arguments.map{|key,value| "&#{key}=#{value}"}.join("")
    end

    def url_root
      "#{Inquisitio.config.search_endpoint}/2011-02-01/search?"
    end
  end
end
