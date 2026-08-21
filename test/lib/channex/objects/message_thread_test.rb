require "test_helper"

class Channex::Objects::MessageThreadTest < ActiveSupport::TestCase
  RESOURCE = {
    "attributes" => {
      "title" => "Maldonado Roxy",
      "is_closed" => false,
      "provider" => "BookingCom",
      "message_count" => 2,
      "last_message" => {
        "attachments" => [],
        "inserted_at" => "2021-07-27T09:43:05.864520",
        "message" => "Thanks for your message.",
        "sender" => "property"
      },
      "last_message_received_at" => "2021-07-27T09:43:05.864520",
      "inserted_at" => "2021-07-27T09:32:14.281622",
      "updated_at" => "2021-07-27T09:43:05.868034"
    },
    "id" => "20d1b08c-190e-4068-a77d-4a909a21835d",
    "relationships" => {
      "booking" => {"data" => {"id" => "4d8240fd-d709-454b-a866-08bca2a5a909", "type" => "booking"}},
      "channel" => {"data" => {"id" => "351f145d-cb8c-4df7-9f12-2f6854991b91", "type" => "channel"}},
      "property" => {"data" => {"id" => "71d34923-a8be-4682-9625-e4a2f080df92", "type" => "property"}}
    },
    "type" => "message_thread"
  }.freeze

  test "from_resource lifts the id and relationships out of the resource node" do
    thread = Channex::Objects::MessageThread.from_resource(RESOURCE)

    assert_equal "20d1b08c-190e-4068-a77d-4a909a21835d", thread.id
    assert_equal "4d8240fd-d709-454b-a866-08bca2a5a909", thread.booking_id
    assert_equal "351f145d-cb8c-4df7-9f12-2f6854991b91", thread.channel_id
    assert_equal "71d34923-a8be-4682-9625-e4a2f080df92", thread.property_id
    assert_equal "Maldonado Roxy", thread.title
    assert_equal "BookingCom", thread.provider
    assert_equal 2, thread.message_count
  end

  test "last_message is wrapped as a message" do
    last_message = Channex::Objects::MessageThread.from_resource(RESOURCE).last_message

    assert_instance_of Channex::Objects::Message, last_message
    assert_equal "Thanks for your message.", last_message.message
    assert_predicate last_message, :from_property?
  end

  test "open and closed reflect is_closed" do
    thread = Channex::Objects::MessageThread.from_resource(RESOURCE)

    assert_predicate thread, :open?
    assert_not_predicate thread, :closed?

    closed = Channex::Objects::MessageThread.new("is_closed" => true)

    assert_predicate closed, :closed?
    assert_not_predicate closed, :open?
  end

  test "an Airbnb inquiry has no booking" do
    inquiry = Channex::Objects::MessageThread.from_resource(
      "id" => "b4153232-2e77-4ccf-8383-ae1119b01bc7",
      "attributes" => {"title" => "Andrew", "provider" => "AirBNB"},
      "relationships" => {
        "property" => {"data" => {"id" => "71d34923-a8be-4682-9625-e4a2f080df92", "type" => "property"}}
      }
    )

    assert_nil inquiry.booking_id
    assert_not_predicate inquiry, :booking?
  end

  test "from_resource returns nil without a node" do
    assert_nil Channex::Objects::MessageThread.from_resource(nil)
  end
end
