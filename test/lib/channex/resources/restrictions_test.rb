require "test_helper"

class Channex::Resources::RestrictionsTest < ActiveSupport::TestCase
  setup do
    @client = mock("client")
    @restrictions = Channex::Resources::Restrictions.new(@client)
  end

  test "list requires property_id" do
    response = mock("response")

    @client.expects(:get).with("/restrictions", params: {filter: {property_id: "prop-123", date: {}}}).returns(response)

    @restrictions.list(property_id: "prop-123")
  end

  test "list with specific date" do
    response = mock("response")

    @client.expects(:get).with("/restrictions", params: {filter: {property_id: "prop-123", date: "2024-01-15"}}).returns(response)

    @restrictions.list(property_id: "prop-123", date: "2024-01-15")
  end

  test "list with date range" do
    response = mock("response")

    @client.expects(:get).with("/restrictions", params: {filter: {property_id: "prop-123", date: {gte: "2024-01-01", lte: "2024-01-31"}}}).returns(response)

    @restrictions.list(property_id: "prop-123", date_from: "2024-01-01", date_to: "2024-01-31")
  end

  test "list with date_from only" do
    response = mock("response")

    @client.expects(:get).with("/restrictions", params: {filter: {property_id: "prop-123", date: {gte: "2024-01-01"}}}).returns(response)

    @restrictions.list(property_id: "prop-123", date_from: "2024-01-01")
  end

  test "list with date_to only" do
    response = mock("response")

    @client.expects(:get).with("/restrictions", params: {filter: {property_id: "prop-123", date: {lte: "2024-01-31"}}}).returns(response)

    @restrictions.list(property_id: "prop-123", date_to: "2024-01-31")
  end

  test "update sends values array" do
    response = mock("response")
    values = [
      {
        property_id: "prop-123",
        rate_plan_id: "rate-456",
        date_from: "2024-01-15",
        date_to: "2024-01-20",
        rate: 15000,
        min_stay_arrival: 2
      }
    ]

    @client.expects(:post).with("/restrictions", body: {values: values}).returns(response)

    @restrictions.update(values)
  end

  test "update with multiple values" do
    response = mock("response")
    values = [
      {property_id: "prop-1", rate_plan_id: "rate-1", date_from: "2024-01-01", date_to: "2024-01-07", rate: 10000},
      {property_id: "prop-1", rate_plan_id: "rate-2", date_from: "2024-01-01", date_to: "2024-01-07", rate: 15000}
    ]

    @client.expects(:post).with("/restrictions", body: {values: values}).returns(response)

    @restrictions.update(values)
  end
end
