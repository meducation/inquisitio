require 'json'
module Inquisitio
  class Document

    attr_reader :type, :id, :version, :fields

    def initialize(type, id, version, fields)
      @type = type
      @id = id
      @version = version
      @fields = fields.reject { |_, v| v.nil? }
    end

    def to_sdf
      "{ \"type\": \"#{type}\", \"id\": \"#{id}\", \"fields\": #{fields.to_json} }"
    end
  end
end
