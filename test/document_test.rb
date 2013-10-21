require File.expand_path('../test_helper', __FILE__)
require 'json'

module Inquisitio
  class DocumentTest < Minitest::Test
    def setup
      @type = 'add'
      @id = '12345'
      @version = 1
      @fields = { :title => 'The Title', :author => 'The Author' }
      @document = Document.new(@type, @id, @version, @fields)

      @expected_SDF = 
        <<-EOS
{ "type": "add",
  "id":   "12345",
  "version": 1,
  "lang": "en",
  "fields": {
    "title": "The Title",
    "author": "The Author"
  }
}
        EOS
    end

    def test_initialization_sets_type
      assert_equal @type, @document.type
    end

    def test_initialization_sets_id
      assert_equal @id, @document.id
    end

    def test_initialization_sets_version
      assert_equal @version, @document.version
    end

    def test_initialization_sets_fields
      assert_equal @fields, @document.fields
    end

    def test_create_valid_SDF_json
      assert_equal JSON.parse(@expected_SDF).to_json,
                   JSON.parse(@document.to_SDF).to_json
    end
  end
end
