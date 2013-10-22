require "inquisitio/version"
require "inquisitio/inquisitio_error"
require "inquisitio/logger"
require "inquisitio/configuration"
require "inquisitio/document"
require "inquisitio/searcher"
require "inquisitio/indexer"

module Inquisitio

  # Inquisitio configuration settings.
  #
  # Settings should be set in an initializer or using some
  # other method that insures they are set before any
  # Inquisitio code is used. They can be set as followed:
  #
  #   Inquisitio.config.access_key = "my-access-key"
  #
  # The following settings are allowed:
  #
  # * <tt>:access_key</tt> - The AWS access key
  # * <tt>:secret_key</tt> - The AWS secret key
  # * <tt>:queue_region</tt> - The AWS region
  #   is included in.
  # * <tt>:logger</tt> - A logger object that responds to puts.
  def self.config
    @config ||= Configuration.new
    if block_given?
      yield @config
    else
      @config
    end
  end

  # Perform a search.
  #
  # @param [String] query The search query.
  # @param [Hash] options. Optionaly specify return_fields. The fields to be returned in the search results.
  def self.search(query, options =  {})
    Searcher.search(query, options)
  end

  # Index a batch of documents.
  #
  # @param [Array] documents. A list of Documents to index.
  def self.index(documents)
    Indexer.index([documents])
  end
end
