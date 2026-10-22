require "test_helper"

class Channex::Objects::MessageTest < ActiveSupport::TestCase
  RESOURCE = {
    "attributes" => {
      "message" => "What time is check-in?",
      "attachments" => [],
      "sender" => "guest",
      "inserted_at" => "2021-07-28T04:25:15.000000",
      "updated_at" => "2021-07-28T04:25:22.613482"
    },
    "id" => "5848b518-07a4-4c8c-a998-2784d638ba30",
    "relationships" => {
      "message_thread" => {
        "data" => {"id" => "4e160f0b-016a-424a-a30d-a9f0a8b1cbaa", "type" => "message_thread"}
      }
    },
    "type" => "message"
  }.freeze

  test "from_resource lifts the id and thread out of the resource node" do
    message = Channex::Objects::Message.from_resource(RESOURCE)

    assert_equal "5848b518-07a4-4c8c-a998-2784d638ba30", message.id
    assert_equal "4e160f0b-016a-424a-a30d-a9f0a8b1cbaa", message.thread_id
    assert_equal "What time is check-in?", message.message
    assert_equal "guest", message.sender
    assert_equal "2021-07-28T04:25:15.000000", message.inserted_at
  end

  test "from_resource keeps the sending user when the property replied" do
    resource = RESOURCE.merge(
      "relationships" => RESOURCE["relationships"].merge(
        "user" => {"data" => {"id" => "c9080091-6b9f-4868-a2ca-691036d29ed0", "type" => "user"}}
      )
    )

    assert_equal "c9080091-6b9f-4868-a2ca-691036d29ed0", Channex::Objects::Message.from_resource(resource).user_id
  end

  test "from_resource returns nil without a node" do
    assert_nil Channex::Objects::Message.from_resource(nil)
  end

  test "from_resource tolerates a node without relationships" do
    message = Channex::Objects::Message.from_resource("id" => "m-1", "attributes" => {"message" => "Hi"})

    assert_equal "m-1", message.id
    assert_nil message.thread_id
  end

  test "sender predicates" do
    assert_predicate Channex::Objects::Message.new("sender" => "guest"), :from_guest?
    assert_predicate Channex::Objects::Message.new("sender" => "property"), :from_property?
    assert_predicate Channex::Objects::Message.new("sender" => "system"), :from_system?
    assert_not_predicate Channex::Objects::Message.new("sender" => "guest"), :from_property?
  end

  test "attachments default to an empty list" do
    message = Channex::Objects::Message.new({})

    assert_empty message.attachments
    assert_not_predicate message, :attachments?
  end

  test "attachment_urls reads both bare URLs and objects" do
    message = Channex::Objects::Message.new(
      "attachments" => ["attachments/photo.jpeg", {"url" => "attachments/receipt.pdf"}]
    )

    assert_equal ["attachments/photo.jpeg", "attachments/receipt.pdf"], message.attachment_urls
    assert_predicate message, :attachments?
  end

  test "meta carries provider extras such as an Airbnb inquiry" do
    message = Channex::Objects::Message.new(
      "message" => "inquiry",
      "sender" => "system",
      "meta" => {"status" => "active", "booking_details" => {"checkin_date" => "2023-12-02"}}
    )

    assert_equal "active", message.meta["status"]
    assert_equal "2023-12-02", message.meta.dig("booking_details", "checkin_date")
  end

  test "meta defaults to an empty hash" do
    assert_empty Channex::Objects::Message.new({}).meta
  end
end
