require "inquisitio/version"
require "inquisitio/inquisitio_error"
require "inquisitio/logger"
require "inquisitio/active_support"

require "inquisitio/configuration"
require "inquisitio/document"
require "inquisitio/search_url_builder"
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

  # Exectues the generated query and returns self.
  #
  # @param query The search query.
  def self.search
    Searcher.search
  end

  # Specify a condition as either a string, an array, or a hash.
  #
  # @param query The search query.
  def self.where(query)
    Searcher.where(query)
  end

  # Specify a page number. Defaults to 1
  #
  # @param query The page number.
  def self.page(page)
    Searcher.page(page)
  end

  # Specify the amount of results you want back
  #
  # @param query The amount of results.
  def self.per(num)
    Searcher.per(num)
  end

  # Specify which fields you want returned.
  #
  # @param query A string or array specifying the fields
  def self.returns(num)
    Searcher.returns(num)
  end

  # Specify any other fields you want to send as part of the request.
  #
  # @param query An array of fields.
  def self.with(num)
    Searcher.with(num)
  end

  # Index a batch of documents.
  #
  # @param [Array] documents. A list of Documents to index.
  def self.index(documents)
    Indexer.index([documents])
  end
end
