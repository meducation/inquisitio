module Inquisitio

  class InquisitioConfigurationError < InquisitioError
  end

  class Configuration

    SETTINGS = [
      :api_version,
      :search_endpoint,
      :document_endpoint,
      :default_search_size,
      :dry_run,
      :logger,
      :max_attempts
    ]

    attr_writer *SETTINGS

    def initialize
      self.logger = Inquisitio::Logger.new
      self.dry_run = false
      self.max_attempts = 3
    end

    SETTINGS.each do |setting|
      define_method setting do
        get_or_raise(setting)
      end
    end

    private

    def get_or_raise(setting)
      val = instance_variable_get("@#{setting.to_s}")
      if setting == :api_version && val.nil?
        val = '2013-01-01'
      end
      val.nil?? raise(InquisitioConfigurationError.new("Configuration for #{setting} is not set")) : val
    end
  end
end

