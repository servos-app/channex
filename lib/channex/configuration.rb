module Channex
  # Configuration for the Channex client
  #
  # @example
  #   Channex.configure do |config|
  #     config.api_key = "your-api-key"
  #     config.environment = :production
  #     config.timeout = 30
  #   end
  #
  class Configuration
    ENVIRONMENTS = {
      staging: "https://staging.channex.io",
      production: "https://app.channex.io",
      secure_staging: "https://secure-staging.channex.io",
      secure_production: "https://secure.channex.io"
    }.freeze

    attr_accessor :api_key, :timeout, :open_timeout, :logger
    attr_reader :environment

    def initialize
      @api_key = nil
      @environment = :staging
      @timeout = 30
      @open_timeout = 10
      @logger = nil
    end

    def environment=(env)
      env = env.to_sym
      unless ENVIRONMENTS.key?(env)
        raise ArgumentError, "Invalid environment: #{env}. Valid options: #{ENVIRONMENTS.keys.join(", ")}"
      end

      @environment = env
    end

    def base_url
      ENVIRONMENTS.fetch(@environment)
    end

    def api_url
      "#{base_url}/api/v1"
    end

    def secure_api_url
      secure_env = (@environment == :production) ? :secure_production : :secure_staging
      "#{ENVIRONMENTS.fetch(secure_env)}/api/v1"
    end
  end
end
