require "test_helper"

class Channex::Resources::PhotosTest < ActiveSupport::TestCase
  setup do
    @client = mock("client")
    @client.stubs(:configuration).returns(Channex::Configuration.new)
    @client.stubs(:api_key).returns("test-key")
    @photos = Channex::Resources::Photos.new(@client)
  end

  test "KINDS constant includes all photo types" do
    assert_equal %w[photo ad menu], Channex::Resources::Photos::KINDS
  end

  test "list with property_id filter" do
    response = mock("response")

    @client.expects(:get).with("/photos", params: {filter: {property_id: "prop-123"}}).returns(response)

    @photos.list(property_id: "prop-123")
  end

  test "list with room_type_id filter" do
    response = mock("response")

    @client.expects(:get).with("/photos", params: {filter: {room_type_id: "room-456"}}).returns(response)

    @photos.list(room_type_id: "room-456")
  end

  test "list with both filters" do
    response = mock("response")

    @client.expects(:get).with("/photos", params: {filter: {property_id: "prop-123", room_type_id: "room-456"}}).returns(response)

    @photos.list(property_id: "prop-123", room_type_id: "room-456")
  end

  test "create wraps attributes in photo key" do
    response = mock("response")
    attributes = {
      property_id: "prop-123",
      url: "https://example.com/photo.jpg",
      position: 0,
      description: "Hotel Lobby"
    }

    @client.expects(:post).with("/photos", body: {"photo" => attributes}).returns(response)

    @photos.create(attributes)
  end

  test "update wraps attributes in photo key" do
    response = mock("response")
    attributes = {position: 1, description: "Updated description"}

    @client.expects(:put).with("/photos/photo-123", body: {"photo" => attributes}).returns(response)

    @photos.update("photo-123", attributes)
  end

  test "reorder sends photos array" do
    response = mock("response")
    photos = [
      {id: "photo-1", position: 0},
      {id: "photo-2", position: 1}
    ]

    @client.expects(:post).with("/photos/reorder", body: {photos: photos}).returns(response)

    @photos.reorder(photos)
  end
end
