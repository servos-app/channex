require "test_helper"

class Channex::Resources::MessageThreadsTest < ActiveSupport::TestCase
  setup do
    @client = mock("client")
    @message_threads = Channex::Resources::MessageThreads.new(@client)
  end

  test "list without filters" do
    @client.expects(:get).with("/message_threads", params: {}).returns(mock("response"))

    @message_threads.list
  end

  test "list filters by property and booking" do
    @client.expects(:get).with(
      "/message_threads",
      params: {filter: {property_id: "prop-123", booking_id: "book-123"}}
    ).returns(mock("response"))

    @message_threads.list(property_id: "prop-123", booking_id: "book-123")
  end

  test "list passes pagination through" do
    @client.expects(:get).with(
      "/message_threads",
      params: {pagination: {page: 2, limit: 50}}
    ).returns(mock("response"))

    @message_threads.list(page: 2, limit: 50)
  end

  test "messages reads the thread's messages" do
    @client.expects(:get).with("/message_threads/thread-123/messages", params: {}).returns(mock("response"))

    @message_threads.messages("thread-123")
  end

  test "messages passes pagination and order through" do
    @client.expects(:get).with(
      "/message_threads/thread-123/messages",
      params: {pagination: {page: 1, limit: 100}, order: {inserted_at: :asc}}
    ).returns(mock("response"))

    @message_threads.messages("thread-123", page: 1, limit: 100, order: {inserted_at: :asc})
  end

  test "send_message posts message text" do
    @client.expects(:post).with(
      "/message_threads/thread-123/messages",
      body: {message: {message: "Check-in is from 15:00."}}
    ).returns(mock("response"))

    @message_threads.send_message("thread-123", message: "Check-in is from 15:00.")
  end

  test "send_message posts an attachment" do
    @client.expects(:post).with(
      "/message_threads/thread-123/messages",
      body: {message: {attachment_id: "attach-123"}}
    ).returns(mock("response"))

    @message_threads.send_message("thread-123", attachment_id: "attach-123")
  end

  test "send_message combines text and attachment" do
    @client.expects(:post).with(
      "/message_threads/thread-123/messages",
      body: {message: {message: "Directions", attachment_id: "attach-123"}}
    ).returns(mock("response"))

    @message_threads.send_message("thread-123", message: "Directions", attachment_id: "attach-123")
  end

  test "close posts to the close action" do
    @client.expects(:post).with("/message_threads/thread-123/close", body: {}).returns(mock("response"))

    @message_threads.close("thread-123")
  end

  test "no_reply_needed posts to the no_reply_needed action" do
    @client.expects(:post).with("/message_threads/thread-123/no_reply_needed", body: {}).returns(mock("response"))

    @message_threads.no_reply_needed("thread-123")
  end

  test "retrieve reads a single thread" do
    @client.expects(:get).with("/message_threads/thread-123").returns(mock("response"))

    @message_threads.retrieve("thread-123")
  end
end
