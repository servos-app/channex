require "test_helper"

class Channex::ResourceTest < ActiveSupport::TestCase
  # Ensure Response is loaded (which also defines Pagination)
  # We reference it so Zeitwerk loads it before we use Pagination
  RESPONSE_CLASS = Channex::Response
  # Create a concrete test resource class
  class TestCategories < Channex::Resource
    protected

    def resource_path
      "/test_categories"
    end

    def filter_keys
      %i[property_id]
    end
  end

  setup do
    @client = mock("client")
    @resource = TestCategories.new(@client)
  end

  test "list calls client.get with resource path" do
    response = mock_response([{"id" => "1"}], {})

    @client.expects(:get).with("/test_categories", params: {}).returns(response)

    result = @resource.list
    assert_equal response, result
  end

  test "list passes pagination params" do
    response = mock_response([], {})

    @client.expects(:get).with("/test_categories", params: {pagination: {page: 2, limit: 25}}).returns(response)

    @resource.list(page: 2, limit: 25)
  end

  test "list passes filter params" do
    response = mock_response([], {})

    @client.expects(:get).with("/test_categories", params: {filter: {property_id: "123"}}).returns(response)

    @resource.list(filter: {property_id: "123"})
  end

  test "list passes order params" do
    response = mock_response([], {})

    @client.expects(:get).with("/test_categories", params: {order: {inserted_at: :asc}}).returns(response)

    @resource.list(order: {inserted_at: :asc})
  end

  test "list passes additional keyword params" do
    response = mock_response([], {})

    @client.expects(:get).with("/test_categories", params: {custom_param: "value"}).returns(response)

    @resource.list(custom_param: "value")
  end

  test "list sends a keyword the resource filters by as a filter" do
    response = mock_response([], {})

    @client.expects(:get).with("/test_categories",
      params: {filter: {status: "active", property_id: "prop-1"}, custom_param: "value"}).returns(response)

    @resource.list(filter: {status: "active"}, property_id: "prop-1", custom_param: "value")
  end

  test "list leaves out a filter keyword that is nil, keeping the filter's own value" do
    response = mock_response([], {})

    @client.expects(:get).with("/test_categories", params: {filter: {property_id: "from-filter"}}).returns(response)

    @resource.list(filter: {property_id: "from-filter"}, property_id: nil)
  end

  test "list lets a filter keyword override the same key in the filter, leaving the caller's hash alone" do
    response = mock_response([], {})
    filter = {property_id: "from-filter", status: "active"}

    @client.expects(:get).with("/test_categories",
      params: {filter: {property_id: "prop-1", status: "active"}}).returns(response)

    @resource.list(filter:, property_id: "prop-1")
    assert_equal({property_id: "from-filter", status: "active"}, filter)
  end

  test "list_all returns all data when no block given" do
    # limit in mock_response is the limit used for pagination calculation, not actual page size
    page1_response = mock_response([{"id" => "1"}, {"id" => "2"}], {"page" => 1, "limit" => 100, "total" => 200})
    page2_response = mock_response([{"id" => "3"}, {"id" => "4"}], {"page" => 2, "limit" => 100, "total" => 200})

    @client.expects(:get).with("/test_categories", params: {pagination: {page: 1, limit: 100}}).returns(page1_response)
    @client.expects(:get).with("/test_categories", params: {pagination: {page: 2, limit: 100}}).returns(page2_response)

    result = @resource.list_all
    assert_equal [{"id" => "1"}, {"id" => "2"}, {"id" => "3"}, {"id" => "4"}], result
  end

  test "list_all yields each page when block given" do
    page1_response = mock_response([{"id" => "1"}], {"page" => 1, "limit" => 100, "total" => 150})
    page2_response = mock_response([{"id" => "2"}], {"page" => 2, "limit" => 100, "total" => 150})

    @client.expects(:get).with("/test_categories", params: {pagination: {page: 1, limit: 100}}).returns(page1_response)
    @client.expects(:get).with("/test_categories", params: {pagination: {page: 2, limit: 100}}).returns(page2_response)

    pages = []
    @resource.list_all { |data| pages << data }

    assert_equal [[{"id" => "1"}], [{"id" => "2"}]], pages
  end

  test "list_all passes filter params" do
    response = mock_response([], {"page" => 1, "limit" => 100, "total" => 0})

    @client.expects(:get).with("/test_categories", params: {pagination: {page: 1, limit: 100}, filter: {status: "active"}}).returns(response)

    @resource.list_all(filter: {status: "active"})
  end

  test "retrieve calls client.get with id" do
    response = mock_response({"id" => "123", "name" => "Test"}, {})

    @client.expects(:get).with("/test_categories/123").returns(response)

    result = @resource.retrieve("123")
    assert_equal response, result
  end

  test "create calls client.post with wrapped attributes" do
    response = mock_response({"id" => "new-id"}, {})

    # The wrap_attributes method uses string key for outer wrapper
    @client.expects(:post).with("/test_categories", body: {"test_category" => {name: "New"}}).returns(response)

    result = @resource.create(name: "New")
    assert_equal response, result
  end

  test "update calls client.put with id and wrapped attributes" do
    response = mock_response({"id" => "123", "name" => "Updated"}, {})

    # The wrap_attributes method uses string key for outer wrapper
    @client.expects(:put).with("/test_categories/123", body: {"test_category" => {name: "Updated"}}).returns(response)

    result = @resource.update("123", name: "Updated")
    assert_equal response, result
  end

  test "delete calls client.delete with id" do
    response = mock_response(nil, {})

    @client.expects(:delete).with("/test_categories/123").returns(response)

    result = @resource.delete("123")
    assert_equal response, result
  end

  test "raises NotImplementedError for resource_path if not overridden" do
    base_resource = Channex::Resource.new(@client)

    assert_raises(NotImplementedError) do
      base_resource.list
    end
  end

  private

  def mock_response(data, meta)
    response = mock
    response.stubs(:data).returns(data)
    response.stubs(:pagination).returns(Channex::Pagination.new(meta))
    response
  end
end
