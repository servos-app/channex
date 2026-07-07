module Channex
  # Error classes for Channex API responses
  module Errors
    # Base error class for all Channex errors
    class Error < StandardError
      attr_reader :response, :code

      def initialize(message = nil, response: nil, code: nil)
        @response = response
        @code = code
        super(message)
      end
    end

    # Raised when authentication fails (401)
    class AuthenticationError < Error; end

    # Raised when the request is forbidden (403)
    class ForbiddenError < Error; end

    # Raised when a resource is not found (404)
    class NotFoundError < Error; end

    # Raised when validation fails (422)
    class ValidationError < Error
      attr_reader :errors

      def initialize(message = nil, errors: [], **kwargs)
        @errors = errors
        super(message, **kwargs)
      end
    end

    # Raised when rate limited (429)
    class RateLimitError < Error
      attr_reader :retry_after

      def initialize(message = nil, retry_after: nil, **kwargs)
        @retry_after = retry_after
        super(message, **kwargs)
      end
    end

    # Raised for server errors (5xx)
    class ServerError < Error; end

    # Raised for connection/network errors
    class ConnectionError < Error; end

    # Raised when request times out
    class TimeoutError < Error; end

    # Raised for invalid configuration
    class ConfigurationError < Error; end
  end
end
