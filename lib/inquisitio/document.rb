require 'json'
module Inquisitio
  class Document

    attr_reader :type, :id, :version, :fields

    def initialize(type, id, version, fields)
      @type = type
      @id = id
      @version = version
      @fields = fields.reject { |k, v| v.nil? }
    end

    def to_SDF
      if Inquisitio.config.api_version == '2011-02-01'
        "{ \"type\": \"#{type}\", \"id\": \"#{id}\", \"version\": #{version}, \"lang\": \"en\", \"fields\": #{fields.to_json} }"
      elsif Inquisitio.config.api_version == '2013-01-01'
        "{ \"type\": \"#{type}\", \"id\": \"#{id}\", \"fields\": #{fields.to_json} }"
      end
    end
  end
end
