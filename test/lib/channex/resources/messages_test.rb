require "test_helper"

class Channex::Resources::MessagesTest < ActiveSupport::TestCase
  setup do
    @client = mock("client")
    @messages = Channex::Resources::Messages.new(@client)
  end

  test "list reads the booking's messages" do
    @client.expects(:get).with("/bookings/book-123/messages", params: {}).returns(mock("response"))

    @messages.list(booking_id: "book-123")
  end

  test "list passes pagination and order through" do
    @client.expects(:get).with(
      "/bookings/book-123/messages",
      params: {pagination: {page: 2, limit: 25}, order: {inserted_at: :asc}}
    ).returns(mock("response"))

    @messages.list(booking_id: "book-123", page: 2, limit: 25, order: {inserted_at: :asc})
  end

  test "send_message posts message text" do
    @client.expects(:post).with(
      "/bookings/book-123/messages",
      body: {message: {message: "Thank you for your reservation!"}}
    ).returns(mock("response"))

    @messages.send_message(booking_id: "book-123", message: "Thank you for your reservation!")
  end

  test "send_message posts an attachment" do
    @client.expects(:post).with(
      "/bookings/book-123/messages",
      body: {message: {attachment_id: "attach-123"}}
    ).returns(mock("response"))

    @messages.send_message(booking_id: "book-123", attachment_id: "attach-123")
  end

  test "messages have no collection of their own" do
    error = assert_raises(NotImplementedError) { @messages.retrieve("message-123") }

    assert_match(/scoped to a booking/, error.message)
  end
end
