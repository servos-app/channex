require "test_helper"

class Channex::Objects::BookingRoomTest < ActiveSupport::TestCase
  setup do
    @data = {
      "ota_unique_id" => "room-123",
      "room_type_id" => "rt-abc",
      "rate_plan_id" => "rp-xyz",
      "checkin_date" => "2024-03-15",
      "checkout_date" => "2024-03-18",
      "amount" => "450.00",
      "occupancy" => {
        "adults" => 2,
        "children" => 1,
        "infants" => 0
      },
      "guests" => [
        {"name" => "John", "surname" => "Doe"},
        {"name" => "Jane", "surname" => "Doe"}
      ],
      "taxes" => [
        {
          "type" => "Value Added Tax (VAT)",
          "name" => "VAT (12%)",
          "total_price" => "75.00",
          "price_per_unit" => "75.00",
          "price_mode" => "Per booking",
          "persons" => 2,
          "nights" => 3,
          "is_inclusive" => true
        }
      ],
      "services" => [
        {
          "type" => "Meal",
          "name" => "Breakfast",
          "total_price" => "30.00",
          "price_per_unit" => "5.00",
          "price_mode" => "Per person per night",
          "persons" => 2,
          "nights" => 3
        }
      ],
      "days" => {
        "2024-03-15" => "150.00",
        "2024-03-16" => "150.00",
        "2024-03-17" => "150.00"
      },
      "meta" => {
        "parent_rate_plan_id" => "parent-rp-123",
        "mapping_id" => "b9a3fd75-cdde-419b-8da8-7ce338e9e302",
        "rate_plan_code" => "13750483",
        "room_type_code" => 376927210,
        "cancel_penalties" => [],
        "days_breakdown" => [],
        "booking_com_room_index" => 509,
        "meal_plan" => "Breakfast is included in the room rate.",
        "roomreservation_id" => "5961909509"
      }
    }
  end

  # Core attributes
  test "provides typed access to core identifiers" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal "room-123", room.ota_unique_id
    assert_equal "rt-abc", room.room_type_id
    assert_equal "rp-xyz", room.rate_plan_id
  end

  test "provides raw date strings" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal "2024-03-15", room.checkin_date
    assert_equal "2024-03-18", room.checkout_date
  end

  test "provides amount" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal "450.00", room.amount
  end

  # Date convenience methods
  test "check_in_date returns parsed Date object" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal Date.new(2024, 3, 15), room.check_in_date
  end

  test "check_out_date returns parsed Date object" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal Date.new(2024, 3, 18), room.check_out_date
  end

  test "check_in_date returns nil when checkin_date is missing" do
    room = Channex::Objects::BookingRoom.new({})

    assert_nil room.check_in_date
  end

  test "check_out_date returns nil when checkout_date is missing" do
    room = Channex::Objects::BookingRoom.new({})

    assert_nil room.check_out_date
  end

  # Nights calculation
  test "nights returns number of nights" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal 3, room.nights
  end

  test "nights returns nil when check_in_date is missing" do
    room = Channex::Objects::BookingRoom.new(@data.except("checkin_date"))

    assert_nil room.nights
  end

  test "nights returns nil when check_out_date is missing" do
    room = Channex::Objects::BookingRoom.new(@data.except("checkout_date"))

    assert_nil room.nights
  end

  test "nights returns 1 for single night stay" do
    room = Channex::Objects::BookingRoom.new(@data.merge(
      "checkin_date" => "2024-03-15",
      "checkout_date" => "2024-03-16"
    ))

    assert_equal 1, room.nights
  end

  # Occupancy (nested)
  test "occupancy is wrapped in Occupancy object" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_instance_of Channex::Objects::Occupancy, room.occupancy
    assert_equal 2, room.occupancy.adults
    assert_equal 1, room.occupancy.children
    assert_equal 0, room.occupancy.infants
  end

  test "occupancy returns nil when not present" do
    room = Channex::Objects::BookingRoom.new({})

    assert_nil room.occupancy
  end

  # Guests (array)
  test "guests is an array of Guest objects" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal 2, room.guests.size
    assert room.guests.all? { |g| g.is_a?(Channex::Objects::Guest) }
  end

  test "guests provides typed access to guest data" do
    room = Channex::Objects::BookingRoom.new(@data)
    guest = room.guests.first

    assert_equal "John", guest.name
    assert_equal "Doe", guest.surname
    assert_equal "John Doe", guest.full_name
  end

  test "guests returns empty array when not present" do
    room = Channex::Objects::BookingRoom.new({})

    assert_equal [], room.guests
  end

  # Taxes (array)
  test "taxes is an array of Tax objects" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal 1, room.taxes.size
    assert_instance_of Channex::Objects::Tax, room.taxes.first
  end

  test "taxes provides typed access to tax data" do
    room = Channex::Objects::BookingRoom.new(@data)
    tax = room.taxes.first

    assert_equal "VAT (12%)", tax.name
    assert_equal "75.00", tax.total_price
    assert tax.inclusive?
    assert_equal "Value Added Tax (VAT)", tax.type
  end

  test "taxes returns empty array when not present" do
    room = Channex::Objects::BookingRoom.new({})

    assert_equal [], room.taxes
  end

  # Services (array)
  test "services is an array of Service objects" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal 1, room.services.size
    assert_instance_of Channex::Objects::Service, room.services.first
  end

  test "services provides typed access to service data" do
    room = Channex::Objects::BookingRoom.new(@data)
    service = room.services.first

    assert_equal "Meal", service.type
    assert_equal "Breakfast", service.name
    assert_equal "30.00", service.total_price
    assert_equal "Per person per night", service.price_mode
  end

  test "services returns empty array when not present" do
    room = Channex::Objects::BookingRoom.new({})

    assert_equal [], room.services
  end

  # Days breakdown
  test "days returns daily price breakdown" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal 3, room.days.size
    assert_equal "150.00", room.days["2024-03-15"]
    assert_equal "150.00", room.days["2024-03-16"]
    assert_equal "150.00", room.days["2024-03-17"]
  end

  test "days returns empty hash when not present" do
    room = Channex::Objects::BookingRoom.new({})

    assert_equal({}, room.days)
  end

  # Meta
  test "meta returns metadata hash" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal "parent-rp-123", room.meta["parent_rate_plan_id"]
  end

  test "meta returns empty hash when not present" do
    room = Channex::Objects::BookingRoom.new({})

    assert_equal({}, room.meta)
  end

  test "parent_rate_plan_id returns value from meta" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal "parent-rp-123", room.parent_rate_plan_id
  end

  test "parent_rate_plan_id returns nil when not in meta" do
    room = Channex::Objects::BookingRoom.new(@data.except("meta"))

    assert_nil room.parent_rate_plan_id
  end

  # Hash access (inherited from Channex::Object)
  test "hash access still works" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal "room-123", room["ota_unique_id"]
    assert_equal "rt-abc", room["room_type_id"]
  end

  test "to_h returns raw data" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal @data, room.to_h
  end

  # Edge cases
  test "handles missing nested data gracefully" do
    room = Channex::Objects::BookingRoom.new({"ota_unique_id" => "123"})

    assert_equal "123", room.ota_unique_id
    assert_nil room.room_type_id
    assert_nil room.rate_plan_id
    assert_nil room.amount
    assert_nil room.occupancy
    assert_equal [], room.guests
    assert_equal [], room.taxes
    assert_equal [], room.services
    assert_equal({}, room.days)
    assert_equal({}, room.meta)
  end

  test "room_reservation_id returns the id from meta" do
    room = Channex::Objects::BookingRoom.new(@data)

    assert_equal "5961909509", room.room_reservation_id
  end
end
