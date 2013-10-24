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
      components << (@filters.empty?? simple_query : boolean_query)
      components << return_fields_query_string
      components << arguments
      components.join("")
    end

    private
    def simple_query
      "q=#{URI.encode(@query.gsub('\'',''))}"
    end

    def boolean_query
      filters = @filters.map{|key,value| "#{key.to_s.gsub('\'','')}:'#{value.to_s.gsub('\'','')}'"}
      queries = filters.join(" ")
      queries = "'#{@query.gsub('\'','')}' #{queries}" if @query
      "bq=#{URI.encode("(and #{queries})")}"
    end

    def return_fields_query_string
      return "" if @return_fields.nil?
      "&return-fields=#{URI::encode(@return_fields.join(',').gsub('\'',''))}"
    end

    def arguments
      return "" if @arguments.nil?
      @arguments.map{|key,value| "&#{key.to_s.gsub('\'','')}=#{value.to_s.gsub('\'','')}"}.join("")
    end

    def url_root
      "#{Inquisitio.config.search_endpoint}/2011-02-01/search?"
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
