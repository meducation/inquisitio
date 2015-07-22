module Inquisitio
  class Facets
    extend Forwardable

    def initialize(facets)
      @facets = JSON.parse(facets.to_json, symbolize_names: true)
    end

    def fields
      @facets.keys
    end

    def_delegator :@facets, :[]

  end
end