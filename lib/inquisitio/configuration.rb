module Inquisitio

  class InquisitioConfigurationError < InquisitioError
  end

  class Configuration

    SETTINGS = [
      :access_key, :secret_key, :queue_region,
      :application_name,
      :logger
    ]
    attr_writer *SETTINGS

    def initialize
      self.logger = Inquisitio::Logger.new
    end

    SETTINGS.each do |setting|
      define_method setting do
        get_or_raise(setting)
      end
    end

    private

    def get_or_raise(setting)
      instance_variable_get("@#{setting.to_s}") || 
        raise(InquisitioConfigurationError.new("Configuration for #{setting} is not set"))
    end
  end
end

