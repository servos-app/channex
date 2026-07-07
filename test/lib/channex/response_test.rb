require "test_helper"

class Channex::ResponseTest < ActiveSupport::TestCase
  test "success? returns true for 2xx status codes" do
    [200, 201, 204, 299].each do |status|
      http_response = mock_http_response(status, "{}")
      response = Channex::Response.new(http_response)
      assert response.success?, "Expected #{status} to be successful"
    end
  end

  test "success? returns false for non-2xx status codes" do
    [199, 301, 400, 401, 403, 404, 422, 429, 500].each do |status|
      http_response = mock_http_response(status, "{}")
      response = Channex::Response.new(http_response)
      assert_not response.success?, "Expected #{status} to not be successful"
    end
  end

  test "data returns the data attribute from body" do
    http_response = mock_http_response(200, '{"data": {"id": "123", "name": "Test"}}')
    response = Channex::Response.new(http_response)

    assert_equal({"id" => "123", "name" => "Test"}, response.data)
  end

  test "data returns nil when not present" do
    http_response = mock_http_response(200, '{"meta": {}}')
    response = Channex::Response.new(http_response)

    assert_nil response.data
  end

  test "meta returns the meta attribute from body" do
    http_response = mock_http_response(200, '{"data": [], "meta": {"page": 1, "total": 10}}')
    response = Channex::Response.new(http_response)

    assert_equal({"page" => 1, "total" => 10}, response.meta)
  end

  test "meta returns empty hash when not present" do
    http_response = mock_http_response(200, '{"data": []}')
    response = Channex::Response.new(http_response)

    assert_equal({}, response.meta)
  end

  test "error returns error from body" do
    http_response = mock_http_response(400, '{"error": {"message": "Bad request"}}')
    response = Channex::Response.new(http_response)

    assert_equal({"message" => "Bad request"}, response.error)
  end

  test "error returns errors from body when error is not present" do
    http_response = mock_http_response(422, '{"errors": {"code": "validation_failed", "title": "Validation failed"}}')
    response = Channex::Response.new(http_response)

    assert_equal({"code" => "validation_failed", "title" => "Validation failed"}, response.error)
  end

  test "error returns nil when neither error nor errors present" do
    http_response = mock_http_response(200, '{"data": {}}')
    response = Channex::Response.new(http_response)

    assert_nil response.error
  end

  test "warnings returns warnings from meta" do
    http_response = mock_http_response(200, '{"data": {}, "meta": {"warnings": [{"message": "Partial success"}]}}')
    response = Channex::Response.new(http_response)

    assert_equal [{"message" => "Partial success"}], response.warnings
  end

  test "warnings returns empty array when not present" do
    http_response = mock_http_response(200, '{"data": {}}')
    response = Channex::Response.new(http_response)

    assert_equal [], response.warnings
  end

  test "raw_body contains original response body" do
    body = '{"data": {"id": "123"}}'
    http_response = mock_http_response(200, body)
    response = Channex::Response.new(http_response)

    assert_equal body, response.raw_body
  end

  test "body is parsed JSON" do
    http_response = mock_http_response(200, '{"data": {"id": "123"}}')
    response = Channex::Response.new(http_response)

    assert_equal({"data" => {"id" => "123"}}, response.body)
  end

  test "body handles empty response" do
    http_response = mock_http_response(204, "")
    response = Channex::Response.new(http_response)

    assert_equal({}, response.body)
  end

  test "body handles nil response" do
    http_response = mock_http_response(204, nil)
    response = Channex::Response.new(http_response)

    assert_equal({}, response.body)
  end

  test "body handles non-JSON response" do
    http_response = mock_http_response(500, "Internal Server Error")
    response = Channex::Response.new(http_response)

    assert_equal({"raw" => "Internal Server Error"}, response.body)
  end

  test "headers are accessible" do
    http_response = mock_http_response(200, "{}", headers: {"Content-Type" => ["application/json"]})
    response = Channex::Response.new(http_response)

    assert_equal({"content-type" => ["application/json"]}, response.headers)
  end

  test "status is accessible" do
    http_response = mock_http_response(201, "{}")
    response = Channex::Response.new(http_response)

    assert_equal 201, response.status
  end

  test "pagination returns Pagination object" do
    http_response = mock_http_response(200, '{"data": [], "meta": {"page": 2, "limit": 25, "total": 100}}')
    response = Channex::Response.new(http_response)

    assert_instance_of Channex::Pagination, response.pagination
    assert_equal 2, response.pagination.page
    assert_equal 25, response.pagination.limit
    assert_equal 100, response.pagination.total
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

# Note: Pagination is defined in lib/channex/response.rb alongside Response
# and is loaded when Channex::Response is first accessed
class Channex::PaginationTest < ActiveSupport::TestCase
  # Ensure Response is loaded (which also defines Pagination)
  setup do
    Channex::Response # trigger autoload
  end

  test "attributes are accessible" do
    meta = {"page" => 2, "limit" => 25, "total" => 100, "order" => "inserted_at:asc"}
    pagination = Channex::Pagination.new(meta)

    assert_equal 2, pagination.page
    assert_equal 25, pagination.limit
    assert_equal 100, pagination.total
    assert_equal "inserted_at:asc", pagination.order
  end

  test "total_pages calculates correctly" do
    pagination = Channex::Pagination.new({"total" => 100, "limit" => 25})
    assert_equal 4, pagination.total_pages

    pagination = Channex::Pagination.new({"total" => 101, "limit" => 25})
    assert_equal 5, pagination.total_pages

    pagination = Channex::Pagination.new({"total" => 0, "limit" => 25})
    assert_equal 0, pagination.total_pages
  end

  test "total_pages returns nil when limit is zero" do
    pagination = Channex::Pagination.new({"total" => 100, "limit" => 0})
    assert_nil pagination.total_pages
  end

  test "total_pages returns nil when limit or total is missing" do
    pagination = Channex::Pagination.new({})
    assert_nil pagination.total_pages

    pagination = Channex::Pagination.new({"total" => 100})
    assert_nil pagination.total_pages
  end

  test "next_page returns next page number" do
    pagination = Channex::Pagination.new({"page" => 2, "limit" => 25, "total" => 100})
    assert_equal 3, pagination.next_page
  end

  test "next_page returns nil on last page" do
    pagination = Channex::Pagination.new({"page" => 4, "limit" => 25, "total" => 100})
    assert_nil pagination.next_page
  end

  test "next_page returns nil when page is missing" do
    pagination = Channex::Pagination.new({"limit" => 25, "total" => 100})
    assert_nil pagination.next_page
  end

  test "prev_page returns previous page number" do
    pagination = Channex::Pagination.new({"page" => 3, "limit" => 25, "total" => 100})
    assert_equal 2, pagination.prev_page
  end

  test "prev_page returns nil on first page" do
    pagination = Channex::Pagination.new({"page" => 1, "limit" => 25, "total" => 100})
    assert_nil pagination.prev_page
  end

  test "prev_page returns nil when page is missing" do
    pagination = Channex::Pagination.new({"limit" => 25, "total" => 100})
    assert_nil pagination.prev_page
  end

  test "has_next? returns boolean" do
    pagination = Channex::Pagination.new({"page" => 2, "limit" => 25, "total" => 100})
    assert pagination.has_next?

    pagination = Channex::Pagination.new({"page" => 4, "limit" => 25, "total" => 100})
    assert_not pagination.has_next?
  end

  test "has_prev? returns boolean" do
    pagination = Channex::Pagination.new({"page" => 2, "limit" => 25, "total" => 100})
    assert pagination.has_prev?

    pagination = Channex::Pagination.new({"page" => 1, "limit" => 25, "total" => 100})
    assert_not pagination.has_prev?
  end
end
