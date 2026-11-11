require "test_helper"

class Channex::Objects::ReviewTest < ActiveSupport::TestCase
  RESOURCE = {
    "attributes" => {
      "content" => "Great location, quiet room.",
      "guest_name" => "Guest",
      "id" => "6f1a3c1e-2b0e-4b9e-9a61-0c3a2f1d5e7b",
      "inserted_at" => "2024-05-02T10:00:00.000000",
      "is_hidden" => false,
      "is_replied" => false,
      "ota" => "BookingCom",
      "ota_reservation_id" => "1234567890",
      "overall_score" => 9.0,
      "received_at" => "2024-05-02T09:58:00.000000",
      "reply" => nil,
      "scores" => [{"category" => "clean", "score" => 10}, {"category" => "value", "score" => 7.5}],
      "tags" => [],
      "updated_at" => "2024-05-02T10:00:00.000000"
    },
    "id" => "6f1a3c1e-2b0e-4b9e-9a61-0c3a2f1d5e7b",
    "relationships" => {
      "booking" => {"data" => {"id" => "4d8240fd-d709-454b-a866-08bca2a5a909", "type" => "booking"}},
      "channel" => {"data" => {"id" => "351f145d-cb8c-4df7-9f12-2f6854991b91", "type" => "channel"}},
      "property" => {"data" => {"id" => "71d34923-a8be-4682-9625-e4a2f080df92", "type" => "property"}}
    },
    "type" => "review"
  }.freeze

  test "from_resource lifts the id and relationships out of the resource node" do
    review = Channex::Objects::Review.from_resource(RESOURCE)

    assert_equal "6f1a3c1e-2b0e-4b9e-9a61-0c3a2f1d5e7b", review.id
    assert_equal "4d8240fd-d709-454b-a866-08bca2a5a909", review.booking_id
    assert_equal "351f145d-cb8c-4df7-9f12-2f6854991b91", review.channel_id
    assert_equal "71d34923-a8be-4682-9625-e4a2f080df92", review.property_id
    assert_equal "BookingCom", review.ota
    assert_in_delta 9.0, review.overall_score
    assert_equal "Great location, quiet room.", review.content
  end

  test "scores are category and score pairs" do
    review = Channex::Objects::Review.from_resource(RESOURCE)

    assert_equal [{"category" => "clean", "score" => 10}, {"category" => "value", "score" => 7.5}], review.scores
  end

  test "scores and tags default to empty" do
    review = Channex::Objects::Review.from_resource("id" => "review-1", "attributes" => {})

    assert_empty review.scores
    assert_empty review.tags
  end

  test "replied and hidden read their flags" do
    review = Channex::Objects::Review.from_resource(RESOURCE)

    assert_not_predicate review, :replied?
    assert_not_predicate review, :hidden?

    replied = Channex::Objects::Review.from_resource(
      RESOURCE.merge("attributes" => RESOURCE["attributes"].merge("is_replied" => true, "is_hidden" => true))
    )

    assert_predicate replied, :replied?
    assert_predicate replied, :hidden?
  end

  test "from_resource returns nil for nil" do
    assert_nil Channex::Objects::Review.from_resource(nil)
  end
end
