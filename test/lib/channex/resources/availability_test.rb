require "test_helper"

class Channex::Resources::AvailabilityTest < ActiveSupport::TestCase
  setup do
    @client = mock("client")
    @availability = Channex::Resources::Availability.new(@client)
  end

  test "list requires property_id" do
    response = mock("response")

    # When no date params are passed, the filter still includes an empty date hash
    @client.expects(:get).with("/availability", params: {filter: {property_id: "prop-123", date: {}}}).returns(response)

    @availability.list(property_id: "prop-123")
  end

  test "list with specific date" do
    response = mock("response")

    @client.expects(:get).with("/availability", params: {filter: {property_id: "prop-123", date: "2024-01-15"}}).returns(response)

    @availability.list(property_id: "prop-123", date: "2024-01-15")
  end

  test "list with date range" do
    response = mock("response")

    @client.expects(:get).with("/availability", params: {filter: {property_id: "prop-123", date: {gte: "2024-01-01", lte: "2024-01-31"}}}).returns(response)

    @availability.list(property_id: "prop-123", date_from: "2024-01-01", date_to: "2024-01-31")
  end

  test "list with date_from only" do
    response = mock("response")

    @client.expects(:get).with("/availability", params: {filter: {property_id: "prop-123", date: {gte: "2024-01-01"}}}).returns(response)

    @availability.list(property_id: "prop-123", date_from: "2024-01-01")
  end

  test "list with date_to only" do
    response = mock("response")

    @client.expects(:get).with("/availability", params: {filter: {property_id: "prop-123", date: {lte: "2024-01-31"}}}).returns(response)

    @availability.list(property_id: "prop-123", date_to: "2024-01-31")
  end

  test "update sends values array" do
    response = mock("response")
    values = [
      {
        property_id: "prop-123",
        room_type_id: "room-456",
        date_from: "2024-01-15",
        date_to: "2024-01-20",
        availability: 5
      }
    ]

    @client.expects(:post).with("/availability", body: {values: values}).returns(response)

    @availability.update(values)
  end

  test "update with multiple values" do
    response = mock("response")
    values = [
      {property_id: "prop-1", room_type_id: "room-1", date_from: "2024-01-01", date_to: "2024-01-07", availability: 3},
      {property_id: "prop-1", room_type_id: "room-2", date_from: "2024-01-01", date_to: "2024-01-07", availability: 5}
    ]

    @client.expects(:post).with("/availability", body: {values: values}).returns(response)

    @availability.update(values)
  end
end
