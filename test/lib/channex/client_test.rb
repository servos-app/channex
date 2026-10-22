require "test_helper"

class Channex::ClientTest < ActiveSupport::TestCase
  test "raises error when initialized without api_key" do
    Channex.reset_configuration!

    assert_raises(Channex::Errors::ConfigurationError) do
      Channex::Client.new
    end
  end

  test "accepts api_key in constructor" do
    client = Channex::Client.new(api_key: "test-api-key")

    assert_equal "test-api-key", client.api_key
  end

  test "uses global configuration api_key when not passed to constructor" do
    Channex.configure do |config|
      config.api_key = "global-api-key"
    end

    client = Channex::Client.new
    assert_equal "global-api-key", client.api_key
  ensure
    Channex.reset_configuration!
  end

  test "constructor api_key overrides global configuration" do
    Channex.configure do |config|
      config.api_key = "global-api-key"
    end

    client = Channex::Client.new(api_key: "local-api-key")
    assert_equal "local-api-key", client.api_key
  ensure
    Channex.reset_configuration!
  end

  test "accepts environment override" do
    client = Channex::Client.new(api_key: "test-key", environment: :production)

    assert_equal :production, client.configuration.environment
    assert_equal "https://app.channex.io/api/v1", client.configuration.api_url
  end

  test "accepts timeout overrides" do
    client = Channex::Client.new(api_key: "test-key", timeout: 60, open_timeout: 20)

    assert_equal 60, client.configuration.timeout
    assert_equal 20, client.configuration.open_timeout
  end

  test "resource accessors return memoized instances" do
    client = Channex::Client.new(api_key: "test-key")

    assert_same client.properties, client.properties
    assert_same client.room_types, client.room_types
    assert_same client.rate_plans, client.rate_plans
    assert_same client.availability, client.availability
    assert_same client.restrictions, client.restrictions
    assert_same client.bookings, client.bookings
    assert_same client.booking_revisions, client.booking_revisions
    assert_same client.channels, client.channels
    assert_same client.webhooks, client.webhooks
    assert_same client.taxes, client.taxes
    assert_same client.tax_sets, client.tax_sets
    assert_same client.photos, client.photos
    assert_same client.groups, client.groups
    assert_same client.group_users, client.group_users
    assert_same client.property_users, client.property_users
    assert_same client.facilities, client.facilities
    assert_same client.messages, client.messages
    assert_same client.message_threads, client.message_threads
    assert_same client.attachments, client.attachments
    assert_same client.hotel_policies, client.hotel_policies
    assert_same client.availability_rules, client.availability_rules
  end

  test "resource accessors return correct resource types" do
    client = Channex::Client.new(api_key: "test-key")

    assert_instance_of Channex::Resources::Properties, client.properties
    assert_instance_of Channex::Resources::RoomTypes, client.room_types
    assert_instance_of Channex::Resources::RatePlans, client.rate_plans
    assert_instance_of Channex::Resources::Availability, client.availability
    assert_instance_of Channex::Resources::Restrictions, client.restrictions
    assert_instance_of Channex::Resources::Bookings, client.bookings
    assert_instance_of Channex::Resources::BookingRevisions, client.booking_revisions
    assert_instance_of Channex::Resources::Channels, client.channels
    assert_instance_of Channex::Resources::Webhooks, client.webhooks
    assert_instance_of Channex::Resources::Taxes, client.taxes
    assert_instance_of Channex::Resources::TaxSets, client.tax_sets
    assert_instance_of Channex::Resources::Photos, client.photos
    assert_instance_of Channex::Resources::Groups, client.groups
    assert_instance_of Channex::Resources::GroupUsers, client.group_users
    assert_instance_of Channex::Resources::PropertyUsers, client.property_users
    assert_instance_of Channex::Resources::Facilities, client.facilities
    assert_instance_of Channex::Resources::Messages, client.messages
    assert_instance_of Channex::Resources::MessageThreads, client.message_threads
    assert_instance_of Channex::Resources::Attachments, client.attachments
    assert_instance_of Channex::Resources::HotelPolicies, client.hotel_policies
    assert_instance_of Channex::Resources::AvailabilityRules, client.availability_rules
  end

  test "get appends trailing slash to path" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    http_response = mock_http_response(200, '{"data": {}}')
    http_mock.expects(:request).with { |req| req.path == "/api/v1/properties/" }.returns(http_response)

    Net::HTTP.stubs(:new).returns(http_mock)

    client.get("/properties")
  end

  test "get includes query params" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    http_response = mock_http_response(200, '{"data": {}}')
    http_mock.expects(:request).with { |req|
      req.path.include?("page=1") && req.path.include?("limit=25")
    }.returns(http_response)

    Net::HTTP.stubs(:new).returns(http_mock)

    client.get("/properties", params: {page: 1, limit: 25})
  end

  test "post sends JSON body" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    http_response = mock_http_response(201, '{"data": {}}')
    http_mock.expects(:request).with { |req|
      req.is_a?(Net::HTTP::Post) &&
        req["Content-Type"] == "application/json" &&
        JSON.parse(req.body) == {"property" => {"title" => "Test"}}
    }.returns(http_response)

    Net::HTTP.stubs(:new).returns(http_mock)

    client.post("/properties", body: {property: {title: "Test"}})
  end

  test "put sends JSON body" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    http_response = mock_http_response(200, '{"data": {}}')
    http_mock.expects(:request).with { |req|
      req.is_a?(Net::HTTP::Put) &&
        JSON.parse(req.body) == {"property" => {"title" => "Updated"}}
    }.returns(http_response)

    Net::HTTP.stubs(:new).returns(http_mock)

    client.put("/properties/123", body: {property: {title: "Updated"}})
  end

  test "delete sends request" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    http_response = mock_http_response(204, "")
    http_mock.expects(:request).with { |req| req.is_a?(Net::HTTP::Delete) }.returns(http_response)

    Net::HTTP.stubs(:new).returns(http_mock)

    client.delete("/properties/123")
  end

  test "sends user-api-key header" do
    client = Channex::Client.new(api_key: "my-secret-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    http_response = mock_http_response(200, '{"data": {}}')
    http_mock.expects(:request).with { |req| req["user-api-key"] == "my-secret-key" }.returns(http_response)

    Net::HTTP.stubs(:new).returns(http_mock)

    client.get("/properties")
  end

  test "raises AuthenticationError on 401" do
    client = Channex::Client.new(api_key: "invalid-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    http_response = mock_http_response(401, '{"error": {"message": "Invalid API key"}}')
    http_mock.stubs(:request).returns(http_response)
    Net::HTTP.stubs(:new).returns(http_mock)

    error = assert_raises(Channex::Errors::AuthenticationError) do
      client.get("/properties")
    end
    assert_equal 401, error.code
    assert_includes error.message, "Invalid API key"
  end

  test "raises ForbiddenError on 403" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    http_response = mock_http_response(403, '{"error": {"message": "Access denied"}}')
    http_mock.stubs(:request).returns(http_response)
    Net::HTTP.stubs(:new).returns(http_mock)

    error = assert_raises(Channex::Errors::ForbiddenError) do
      client.get("/properties/123")
    end
    assert_equal 403, error.code
  end

  test "raises NotFoundError on 404" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    http_response = mock_http_response(404, '{"error": {"message": "Not found"}}')
    http_mock.stubs(:request).returns(http_response)
    Net::HTTP.stubs(:new).returns(http_mock)

    error = assert_raises(Channex::Errors::NotFoundError) do
      client.get("/properties/non-existent")
    end
    assert_equal 404, error.code
  end

  test "raises ValidationError on 422" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    http_response = mock_http_response(422, '{"error": {"message": "Validation failed", "errors": ["Title is required"]}}')
    http_mock.stubs(:request).returns(http_response)
    Net::HTTP.stubs(:new).returns(http_mock)

    error = assert_raises(Channex::Errors::ValidationError) do
      client.post("/properties", body: {})
    end
    assert_equal 422, error.code
    assert_includes error.message, "Validation failed"
  end

  test "raises RateLimitError on 429" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    http_response = mock_http_response(429, '{"error": {"message": "Rate limit exceeded"}}', headers: {"Retry-After" => ["60"]})
    http_mock.stubs(:request).returns(http_response)
    Net::HTTP.stubs(:new).returns(http_mock)

    error = assert_raises(Channex::Errors::RateLimitError) do
      client.get("/properties")
    end
    assert_equal 429, error.code
    assert_equal 60, error.retry_after
  end

  test "raises ServerError on 5xx" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    http_response = mock_http_response(503, '{"error": {"message": "Service unavailable"}}')
    http_mock.stubs(:request).returns(http_response)
    Net::HTTP.stubs(:new).returns(http_mock)

    error = assert_raises(Channex::Errors::ServerError) do
      client.get("/properties")
    end
    assert_equal 503, error.code
  end

  test "raises ConnectionError on network failures" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)
    http_mock.stubs(:request).raises(Errno::ECONNREFUSED)
    Net::HTTP.stubs(:new).returns(http_mock)

    assert_raises(Channex::Errors::ConnectionError) do
      client.get("/properties")
    end
  end

  test "raises TimeoutError on read timeout" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)
    http_mock.stubs(:request).raises(Net::ReadTimeout)
    Net::HTTP.stubs(:new).returns(http_mock)

    assert_raises(Channex::Errors::TimeoutError) do
      client.get("/properties")
    end
  end

  test "raises TimeoutError on open timeout" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)
    http_mock.stubs(:request).raises(Net::OpenTimeout)
    Net::HTTP.stubs(:new).returns(http_mock)

    assert_raises(Channex::Errors::TimeoutError) do
      client.get("/properties")
    end
  end

  test "flattens nested params" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    http_response = mock_http_response(200, '{"data": {}}')
    http_mock.expects(:request).with { |req|
      req.path.include?("filter%5Bproperty_id%5D=123")
    }.returns(http_response)

    Net::HTTP.stubs(:new).returns(http_mock)

    client.get("/availability", params: {filter: {property_id: "123"}})
  end

  test "extracts error message from errors format with title" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    http_response = mock_http_response(422, '{"errors": {"code": "validation_error", "title": "Property ID is required"}}')
    http_mock.stubs(:request).returns(http_response)
    Net::HTTP.stubs(:new).returns(http_mock)

    error = assert_raises(Channex::Errors::ValidationError) do
      client.post("/properties", body: {})
    end
    assert_includes error.message, "Property ID is required"
  end

  test "names the fields Channex rejected, never the values it echoes" do
    client = Channex::Client.new(api_key: "test-key", environment: :staging)

    http_mock = mock("http")
    http_mock.stubs(:use_ssl=)
    http_mock.stubs(:read_timeout=)
    http_mock.stubs(:open_timeout=)

    body = {errors: {code: "validation_error", title: "Validation Error",
                     details: {count_of_rooms: ["must be greater than 0, got 0"], title: ["is taken: Crew"]}}}
    http_mock.stubs(:request).returns(mock_http_response(422, body.to_json))
    Net::HTTP.stubs(:new).returns(http_mock)

    error = assert_raises(Channex::Errors::ValidationError) { client.post("/room_types", body: {}) }

    assert_equal "Validation Error: count_of_rooms, title", error.message
    assert_equal %w[count_of_rooms title], error.errors.map(&:first)
  end

  private

  def mock_http_response(code, body, headers: {})
    response = mock
    response.stubs(:code).returns(code.to_s)
    response.stubs(:body).returns(body)
    response.stubs(:to_hash).returns(headers.transform_keys(&:downcase))
    response
  end
end
