require "test_helper"

class Channex::Resources::ChannelsTest < ActiveSupport::TestCase
  setup do
    @client = mock("client")
    @channels = Channex::Resources::Channels.new(@client)
  end

  test "list with property_id filter" do
    response = mock("response")

    @client.expects(:get).with("/channels", params: {filter: {property_id: "prop-123"}}).returns(response)

    @channels.list(property_id: "prop-123")
  end

  test "test_connection posts channel and settings" do
    response = mock("response")

    @client.expects(:post).with(
      "/channels/test_connection",
      body: {channel: "BookingCom", settings: {hotel_id: "6519420"}}
    ).returns(response)

    @channels.test_connection(channel: "BookingCom", settings: {hotel_id: "6519420"})
  end

  test "mapping_details posts channel and settings" do
    response = mock("response")

    @client.expects(:post).with(
      "/channels/mapping_details",
      body: {channel: "BookingCom", settings: {hotel_id: "6519420"}}
    ).returns(response)

    @channels.mapping_details(channel: "BookingCom", settings: {hotel_id: "6519420"})
  end

  test "connect wraps attributes in channel key" do
    response = mock("response")
    attributes = {channel: "BookingCom", group_id: "grp-1", properties: ["prop-123"]}

    @client.expects(:post).with("/channels", body: {"channel" => attributes}).returns(response)

    @channels.connect(attributes)
  end

  test "activate posts to the activate path" do
    response = mock("response")

    @client.expects(:post).with("/channels/ch-123/activate", body: {}).returns(response)

    @channels.activate("ch-123")
  end

  test "deactivate posts to the deactivate path" do
    response = mock("response")

    @client.expects(:post).with("/channels/ch-123/deactivate", body: {}).returns(response)

    @channels.deactivate("ch-123")
  end

  test "disconnect deletes the channel" do
    response = mock("response")

    @client.expects(:delete).with("/channels/ch-123").returns(response)

    @channels.disconnect("ch-123")
  end
end
