require File.expand_path('../test_helper', __FILE__)
require 'json'

module Inquisitio
  class DocumentTest < Minitest::Test

    def test_initialization_sets_type
      document = Document.new('add', '12345', 1, {:title => 'The Title', :author => 'The Author'})
      assert_equal 'add', document.type
    end

    def test_initialization_sets_id
      document = Document.new('add', '12345', 1, {:title => 'The Title', :author => 'The Author'})
      assert_equal '12345', document.id
    end

    def test_initialization_sets_version
      document = Document.new('add', '12345', 1, {:title => 'The Title', :author => 'The Author'})
      assert_equal 1, document.version
    end

    def test_initialization_sets_fields
      fields = {:title => 'The Title', :author => 'The Author'}
      document = Document.new('add', '12345', 1, fields)
      assert_equal fields, document.fields
    end

    def test_create_valid_SDF_json
      expected_SDF = '{ "type": "add", "id": "12345", "fields": { "title": "The Title", "author": "The Author" } }'
      document = Document.new('add', '12345', 1, {:title => 'The Title', :author => 'The Author'})
      assert_equal JSON.parse(expected_SDF).to_json, JSON.parse(document.to_sdf).to_json
    end

    def test_should_ignore_null_field_values_when_creating_SDF_json
      expected_SDF = '{ "type": "add", "id": "12345", "fields": { "title": "The Title" } }'
      fields = {:title => 'The Title', :author => nil}
      document = Document.new('add', '12345', 1, fields)
      assert_equal JSON.parse(expected_SDF).to_json, JSON.parse(document.to_sdf).to_json
    end
  end
end
