require "test_helper"

class Channex::Resources::WebhooksTest < ActiveSupport::TestCase
  setup do
    @client = mock("client")
    @webhooks = Channex::Resources::Webhooks.new(@client)
  end

  test "EVENTS constant includes all event types" do
    expected_events = %w[
      ari
      booking
      booking_new
      booking_modification
      booking_cancellation
      reservation_request
      new_channel
      updated_channel
      disconnected_channel
      message
    ]

    assert_equal expected_events, Channex::Resources::Webhooks::EVENTS
  end

  test "list with property_id filter" do
    response = mock("response")

    @client.expects(:get).with("/webhooks", params: {filter: {property_id: "prop-123"}}).returns(response)

    @webhooks.list(property_id: "prop-123")
  end

  test "create wraps attributes in webhook key" do
    response = mock("response")
    attributes = {
      callback_url: "https://example.com/webhook",
      property_id: "prop-123",
      event_mask: "booking"
    }

    @client.expects(:post).with("/webhooks", body: {webhook: attributes}).returns(response)

    @webhooks.create(attributes)
  end

  test "update wraps attributes in webhook key" do
    response = mock("response")

    @client.expects(:put).with("/webhooks/wh-123", body: {webhook: {callback_url: "https://new.url"}}).returns(response)

    @webhooks.update("wh-123", callback_url: "https://new.url")
  end

  test "test_new sends webhook params" do
    response = mock("response")
    params = {
      callback_url: "https://example.com/webhook",
      event_mask: "booking",
      property_id: "prop-123"
    }

    @client.expects(:post).with("/webhooks/test", body: {webhook: params}).returns(response)

    @webhooks.test_new(params)
  end

  test "test sends webhook id" do
    response = mock("response")

    @client.expects(:post).with("/webhooks/wh-123/test", body: {}).returns(response)

    @webhooks.test("wh-123")
  end
end
