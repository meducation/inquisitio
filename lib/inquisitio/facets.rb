module Inquisitio
  class Facets < Hash

    def initialize(facets)
      super
      hash = facets.nil? ? {} : JSON.parse(facets.to_json, symbolize_names: true)
      merge!(hash)
    end

    def fields
      keys
    end
  end
end
