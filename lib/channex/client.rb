module Channex
  # Main client for interacting with the Channex API
  #
  # @example Basic usage
  #   client = Channex::Client.new(api_key: "your-api-key")
  #   client.properties.list
  #
  # @example With environment override
  #   client = Channex::Client.new(
  #     api_key: "your-api-key",
  #     environment: :production
  #   )
  #
  class Client
    attr_reader :api_key, :configuration

    def initialize(api_key: nil, environment: nil, timeout: nil, open_timeout: nil)
      @configuration = Configuration.new
      @configuration.api_key = api_key || Channex.configuration.api_key
      @configuration.environment = environment || Channex.configuration.environment
      @configuration.timeout = timeout || Channex.configuration.timeout
      @configuration.open_timeout = open_timeout || Channex.configuration.open_timeout
      @configuration.logger = Channex.configuration.logger

      @api_key = @configuration.api_key

      validate_configuration!
    end

    # Resource accessors

    def properties
      @properties ||= Resources::Properties.new(self)
    end

    def room_types
      @room_types ||= Resources::RoomTypes.new(self)
    end

    def rate_plans
      @rate_plans ||= Resources::RatePlans.new(self)
    end

    def availability
      @availability ||= Resources::Availability.new(self)
    end

    def restrictions
      @restrictions ||= Resources::Restrictions.new(self)
    end

    def bookings
      @bookings ||= Resources::Bookings.new(self)
    end

    def booking_revisions
      @booking_revisions ||= Resources::BookingRevisions.new(self)
    end

    def channels
      @channels ||= Resources::Channels.new(self)
    end

    def webhooks
      @webhooks ||= Resources::Webhooks.new(self)
    end

    def taxes
      @taxes ||= Resources::Taxes.new(self)
    end

    def tax_sets
      @tax_sets ||= Resources::TaxSets.new(self)
    end

    def photos
      @photos ||= Resources::Photos.new(self)
    end

    def groups
      @groups ||= Resources::Groups.new(self)
    end

    def group_users
      @group_users ||= Resources::GroupUsers.new(self)
    end

    def property_users
      @property_users ||= Resources::PropertyUsers.new(self)
    end

    def facilities
      @facilities ||= Resources::Facilities.new(self)
    end

    def messages
      @messages ||= Resources::Messages.new(self)
    end

    def message_threads
      @message_threads ||= Resources::MessageThreads.new(self)
    end

    def attachments
      @attachments ||= Resources::Attachments.new(self)
    end

    def hotel_policies
      @hotel_policies ||= Resources::HotelPolicies.new(self)
    end

    def availability_rules
      @availability_rules ||= Resources::AvailabilityRules.new(self)
    end

    # HTTP methods

    def get(path, params: {})
      request(:get, path, params: params)
    end

    def post(path, body: {})
      request(:post, path, body: body)
    end

    def put(path, body: {})
      request(:put, path, body: body)
    end

    def delete(path)
      request(:delete, path)
    end

    private

    def validate_configuration!
      if @api_key.nil? || @api_key.empty?
        raise Errors::ConfigurationError, "API key is required. Set via Channex.configure or pass to Client.new"
      end
    end

    def request(method, path, params: {}, body: nil)
      uri = build_uri(path, params)
      http = build_http(uri)
      request = build_request(method, uri, body)

      log_request(method, uri, body)

      response = execute_request(http, request)
      channex_response = Response.new(response)

      log_response(channex_response)
      handle_errors(channex_response)

      channex_response
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError => e
      raise Errors::ConnectionError.new("Connection failed: #{e.message}")
    rescue Net::OpenTimeout
      raise Errors::TimeoutError.new("Connection timed out")
    rescue Net::ReadTimeout
      raise Errors::TimeoutError.new("Request timed out")
    end

    def build_uri(path, params)
      url = "#{configuration.api_url}#{path}"
      url += "/" unless url.end_with?("/")

      uri = URI(url)
      uri.query = URI.encode_www_form(flatten_params(params)) unless params.empty?
      uri
    end

    def build_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = configuration.timeout
      http.open_timeout = configuration.open_timeout
      http
    end

    def build_request(method, uri, body)
      request_class = {
        get: Net::HTTP::Get,
        post: Net::HTTP::Post,
        put: Net::HTTP::Put,
        delete: Net::HTTP::Delete
      }.fetch(method)

      request = request_class.new(uri)
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request["user-api-key"] = api_key
      request.body = body.to_json if body.present?

      request
    end

    def execute_request(http, request)
      http.request(request)
    end

    def flatten_params(params, prefix = nil)
      params.each_with_object([]) do |(key, value), result|
        prefixed_key = prefix ? "#{prefix}[#{key}]" : key.to_s

        case value
        when Hash
          result.concat(flatten_params(value, prefixed_key))
        when Array
          value.each { |v| result << ["#{prefixed_key}[]", v.to_s] }
        else
          result << [prefixed_key, value.to_s]
        end
      end
    end

    def handle_errors(response)
      return if response.success?

      error_message = extract_error_message(response)

      case response.status
      when 401
        raise Errors::AuthenticationError.new(error_message, response: response, code: 401)
      when 403
        raise Errors::ForbiddenError.new(error_message, response: response, code: 403)
      when 404
        raise Errors::NotFoundError.new(error_message, response: response, code: 404)
      when 422
        raise Errors::ValidationError.new(
          error_message,
          errors: (response.error["details"] if response.error.is_a?(Hash)) || {},
          response: response,
          code: 422
        )
      when 429
        retry_after = response.headers["retry-after"]&.first&.to_i
        raise Errors::RateLimitError.new(
          error_message,
          retry_after: retry_after,
          response: response,
          code: 429
        )
      when 500..599
        raise Errors::ServerError.new(error_message, response: response, code: response.status)
      else
        raise Errors::Error.new(error_message, response: response, code: response.status)
      end
    end

    def extract_error_message(response)
      error = response.error
      if error.is_a?(Hash)
        # Handle both error formats:
        # - { "message": "..." } or { "error": "..." }
        # - { "code": "...", "title": "..." }
        error["message"] || error["title"] || error["error"] || error.to_s
      elsif error.is_a?(String)
        error
      else
        "HTTP #{response.status}"
      end
    end

    def log_request(method, uri, body)
      return unless configuration.logger

      configuration.logger.debug "[Channex] #{method.upcase} #{uri}"
      configuration.logger.debug "[Channex] Body: #{body.to_json}" if body
    end

    def log_response(response)
      return unless configuration.logger

      configuration.logger.debug "[Channex] Response: #{response.status}"
      configuration.logger.debug "[Channex] Body: #{response.raw_body}" if response.raw_body
    end
  end
end
