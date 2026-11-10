require "test_helper"

class Channex::Resources::ReviewsTest < ActiveSupport::TestCase
  setup do
    @client = mock("client")
    @reviews = Channex::Resources::Reviews.new(@client)
  end

  test "list filters by property and booking" do
    @client.expects(:get).with(
      "/reviews",
      params: {filter: {property_id: "prop-123", booking_id: "book-123"}}
    ).returns(mock("response"))

    @reviews.list(property_id: "prop-123", booking_id: "book-123")
  end

  test "list passes pagination through" do
    @client.expects(:get).with("/reviews", params: {pagination: {page: 2, limit: 50}}).returns(mock("response"))

    @reviews.list(page: 2, limit: 50)
  end

  test "retrieve reads one review" do
    @client.expects(:get).with("/reviews/review-123").returns(mock("response"))

    @reviews.retrieve("review-123")
  end

  test "reply posts the reply text" do
    @client.expects(:post).with(
      "/reviews/review-123/reply",
      body: {reply: {reply: "Thank you for staying with us."}}
    ).returns(mock("response"))

    @reviews.reply("review-123", reply: "Thank you for staying with us.")
  end
end
