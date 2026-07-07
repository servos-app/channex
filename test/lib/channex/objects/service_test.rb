require "test_helper"

class Channex::Objects::ServiceTest < ActiveSupport::TestCase
  setup do
    @data = {
      "type" => "Fee",
      "name" => "Cleaning Fee",
      "total_price" => "30.00",
      "price_per_unit" => "15.00",
      "price_mode" => "Per night",
      "persons" => 1,
      "nights" => 2,
      "room_index" => 0,
      "is_inclusive" => true
    }
  end

  # Core attributes
  test "provides typed access to type" do
    service = Channex::Objects::Service.new(@data)

    assert_equal "Fee", service.type
  end

  test "provides typed access to name" do
    service = Channex::Objects::Service.new(@data)

    assert_equal "Cleaning Fee", service.name
  end

  test "provides typed access to total_price" do
    service = Channex::Objects::Service.new(@data)

    assert_equal "30.00", service.total_price
  end

  test "provides typed access to price_per_unit" do
    service = Channex::Objects::Service.new(@data)

    assert_equal "15.00", service.price_per_unit
  end

  test "provides typed access to price_mode" do
    service = Channex::Objects::Service.new(@data)

    assert_equal "Per night", service.price_mode
  end

  test "provides typed access to persons" do
    service = Channex::Objects::Service.new(@data)

    assert_equal 1, service.persons
  end

  test "provides typed access to nights" do
    service = Channex::Objects::Service.new(@data)

    assert_equal 2, service.nights
  end

  test "provides typed access to room_index" do
    service = Channex::Objects::Service.new(@data)

    assert_equal 0, service.room_index
  end

  # Inclusive flag — Channex sends this as `is_inclusive`
  test "provides typed access to inclusive via is_inclusive key" do
    service = Channex::Objects::Service.new(@data)

    assert_equal true, service.inclusive
  end

  test "inclusive? returns true when is_inclusive is true" do
    service = Channex::Objects::Service.new(@data.merge("is_inclusive" => true))

    assert service.inclusive?
  end

  test "inclusive? returns false when is_inclusive is false" do
    service = Channex::Objects::Service.new(@data.merge("is_inclusive" => false))

    assert_not service.inclusive?
  end

  test "inclusive? returns false when is_inclusive is missing" do
    service = Channex::Objects::Service.new(@data.except("is_inclusive"))

    assert_not service.inclusive?
  end

  # Service types — Channex distinguishes meals, fees, and extras via `type`
  test "handles Meal type" do
    service = Channex::Objects::Service.new(@data.merge("type" => "Meal", "name" => "Breakfast"))

    assert_equal "Meal", service.type
    assert_equal "Breakfast", service.name
  end

  test "handles Extra type" do
    service = Channex::Objects::Service.new(@data.merge("type" => "Extra", "name" => "Airport Transfer"))

    assert_equal "Extra", service.type
    assert_equal "Airport Transfer", service.name
  end

  # Real Booking.com cancellation-fee payload (via Channex). Note the `type` is
  # the specific "Cancellation Fee", not the generic "Fee" the API docs imply.
  test "represents a cancellation fee as observed from Booking.com" do
    service = Channex::Objects::Service.new(
      "type" => "Cancellation Fee",
      "name" => "Cancellation Fee",
      "total_price" => "12240.00",
      "price_per_unit" => "12240.00",
      "price_mode" => "Per stay",
      "persons" => 0,
      "nights" => 0,
      "is_inclusive" => true
    )

    assert_equal "Cancellation Fee", service.type
    assert_equal "Cancellation Fee", service.name
    assert_equal "12240.00", service.total_price
    assert_equal "Per stay", service.price_mode
    assert service.inclusive?
  end

  # Price modes
  test "handles per-stay price mode" do
    service = Channex::Objects::Service.new(@data.merge("price_mode" => "Per stay"))

    assert_equal "Per stay", service.price_mode
  end

  test "handles per-person-per-night price mode" do
    service = Channex::Objects::Service.new(@data.merge("price_mode" => "Per person per night"))

    assert_equal "Per person per night", service.price_mode
  end

  # Hash access (inherited from Channex::Object)
  test "hash access still works" do
    service = Channex::Objects::Service.new(@data)

    assert_equal "Cleaning Fee", service["name"]
    assert_equal "30.00", service["total_price"]
  end

  test "to_h returns raw data" do
    service = Channex::Objects::Service.new(@data)

    assert_equal @data, service.to_h
  end

  # Edge cases
  test "handles missing data gracefully" do
    service = Channex::Objects::Service.new({})

    assert_nil service.type
    assert_nil service.name
    assert_nil service.total_price
    assert_nil service.price_per_unit
    assert_nil service.price_mode
    assert_nil service.persons
    assert_nil service.nights
    assert_nil service.room_index
    assert_nil service.inclusive
    assert_not service.inclusive?
  end

  test "room_index is optional" do
    service = Channex::Objects::Service.new(@data.except("room_index"))

    assert_nil service.room_index
  end
end
