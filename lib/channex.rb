require "net/http"
require "json"
require "uri"
require "zeitwerk"
require "active_support"
require "active_support/core_ext/hash/slice"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"

loader = Zeitwerk::Loader.for_gem
loader.setup

# Channex API Ruby client
#
# A clean, idiomatic Ruby library for interacting with the Channex.io
# channel manager API. Supports properties, room types, rate plans,
# availability, bookings, and more.
#
# @example Basic usage
#   client = Channex::Client.new(api_key: "your-api-key")
#   properties = client.properties.list
#   property = client.properties.retrieve("property-uuid")
#
# @example With global configuration
#   Channex.configure do |config|
#     config.api_key = "your-api-key"
#     config.environment = :production
#   end
#
#   client = Channex::Client.new
#   client.properties.list
#
module Channex
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end

loader.eager_load
