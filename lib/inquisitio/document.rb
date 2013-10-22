require 'json'
module Inquisitio
  class Document

    attr_reader :type, :id, :version, :fields
    def initialize(type, id, version, fields)
      @type = type
      @id = id
      @version = version
      @fields = fields
    end

    def to_SDF
      <<-EOS
{ "type": "#{type}",
  "id":   "#{id}",
  "version": #{version},
  "lang": "en",
  "fields": #{fields.to_json}
}
      EOS
    end
  end
end
