require "test_helper"

class Channex::Objects::BookingRevisionTest < ActiveSupport::TestCase
  setup do
    @data = {
      "id" => "rev-123",
      "booking_id" => "booking-456",
      "property_id" => "prop-789",
      "unique_id" => "OTA-12345",
      "system_id" => "sys-001",
      "ota_name" => "Booking.com",
      "ota_reservation_code" => "BDC-98765",
      "status" => "new",
      "inserted_at" => "2024-03-01T10:30:00Z",
      "arrival_date" => "2024-03-15",
      "departure_date" => "2024-03-18",
      "arrival_hour" => "14:00",
      "amount" => "450.00",
      "currency" => "EUR",
      "ota_commission" => "45.00",
      "payment_collect" => "property",
      "payment_type" => "credit_card",
      "notes" => "Late check-in requested",
      "customer" => {
        "name" => "John",
        "surname" => "Doe",
        "mail" => "john@example.com",
        "phone" => "+1234567890",
        "country" => "US",
        "city" => "New York",
        "company" => {
          "title" => "Acme Corp",
          "number" => "VAT123",
          "number_type" => "vat"
        }
      },
      "occupancy" => {
        "adults" => 2,
        "children" => 1,
        "infants" => 0
      },
      "rooms" => [
        {
          "ota_unique_id" => "room-1",
          "room_type_id" => "rt-abc",
          "rate_plan_id" => "rp-xyz",
          "checkin_date" => "2024-03-15",
          "checkout_date" => "2024-03-18",
          "amount" => "450.00",
          "occupancy" => {"adults" => 2, "children" => 1, "infants" => 0},
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
          "days" => {
            "2024-03-15" => "150.00",
            "2024-03-16" => "150.00",
            "2024-03-17" => "150.00"
          }
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
      "guarantee" => {
        "card_type" => "visa",
        "card_number" => "4111111111111111",
        "cardholder_name" => "John Doe",
        "expiration_date" => "12/25",
        "cvv" => "123"
      }
    }
  end

  # Core identifiers
  test "provides typed access to core identifiers" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_equal "rev-123", revision.id
    assert_equal "booking-456", revision.booking_id
    assert_equal "prop-789", revision.property_id
    assert_equal "OTA-12345", revision.unique_id
    assert_equal "sys-001", revision.system_id
  end

  # OTA information
  test "provides typed access to OTA information" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_equal "Booking.com", revision.ota_name
    assert_equal "BDC-98765", revision.ota_reservation_code
  end

  # Status
  test "provides typed access to status" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_equal "new", revision.status
  end

  test "status helpers work correctly" do
    new_revision = Channex::Objects::BookingRevision.new(@data.merge("status" => "new"))
    assert new_revision.new?
    assert_not new_revision.modified?
    assert_not new_revision.cancelled?

    modified_revision = Channex::Objects::BookingRevision.new(@data.merge("status" => "modified"))
    assert_not modified_revision.new?
    assert modified_revision.modified?
    assert_not modified_revision.cancelled?

    cancelled_revision = Channex::Objects::BookingRevision.new(@data.merge("status" => "cancelled"))
    assert_not cancelled_revision.new?
    assert_not cancelled_revision.modified?
    assert cancelled_revision.cancelled?
  end

  # Dates
  test "provides raw date strings" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_equal "2024-03-15", revision.arrival_date
    assert_equal "2024-03-18", revision.departure_date
    assert_equal "14:00", revision.arrival_hour
  end

  test "provides parsed Date objects via convenience methods" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_equal Date.new(2024, 3, 15), revision.check_in_date
    assert_equal Date.new(2024, 3, 18), revision.check_out_date
  end

  test "date convenience methods return nil when date is missing" do
    revision = Channex::Objects::BookingRevision.new({})

    assert_nil revision.check_in_date
    assert_nil revision.check_out_date
  end

  test "received_at parses timestamp" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_equal Time.parse("2024-03-01T10:30:00Z"), revision.received_at
  end

  # Financial
  test "provides typed access to financial data" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_equal "450.00", revision.amount
    assert_equal "EUR", revision.currency
    assert_equal "45.00", revision.ota_commission
  end

  # Payment
  test "provides payment information" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_equal "property", revision.payment_collect
    assert_equal "credit_card", revision.payment_type
  end

  test "collect_payment? returns true for property or nil" do
    property_revision = Channex::Objects::BookingRevision.new(@data.merge("payment_collect" => "property"))
    assert property_revision.collect_payment?

    nil_revision = Channex::Objects::BookingRevision.new(@data.merge("payment_collect" => nil))
    assert nil_revision.collect_payment?

    ota_revision = Channex::Objects::BookingRevision.new(@data.merge("payment_collect" => "ota"))
    assert_not ota_revision.collect_payment?
  end

  test "prepaid? returns true only for ota payment_collect" do
    ota_revision = Channex::Objects::BookingRevision.new(@data.merge("payment_collect" => "ota"))
    assert ota_revision.prepaid?

    property_revision = Channex::Objects::BookingRevision.new(@data.merge("payment_collect" => "property"))
    assert_not property_revision.prepaid?
  end

  # Notes
  test "provides notes" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_equal "Late check-in requested", revision.notes
  end

  # Customer (nested)
  test "customer is wrapped in Customer object" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_instance_of Channex::Objects::Customer, revision.customer
    assert_equal "John", revision.customer.name
    assert_equal "Doe", revision.customer.surname
    assert_equal "John Doe", revision.customer.full_name
    assert_equal "john@example.com", revision.customer.mail
    assert_equal "john@example.com", revision.customer.email  # alias
    assert_equal "+1234567890", revision.customer.phone
    assert_equal "US", revision.customer.country
    assert_equal "New York", revision.customer.city
  end

  test "customer company is wrapped" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_instance_of Channex::Objects::Company, revision.customer.company
    assert_equal "Acme Corp", revision.customer.company.title
    assert_equal "VAT123", revision.customer.company.number
    assert_equal "vat", revision.customer.company.number_type
  end

  test "customer returns nil when not present" do
    revision = Channex::Objects::BookingRevision.new({})

    assert_nil revision.customer
  end

  # Occupancy (nested)
  test "occupancy is wrapped in Occupancy object" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_instance_of Channex::Objects::Occupancy, revision.occupancy
    assert_equal 2, revision.occupancy.adults
    assert_equal 1, revision.occupancy.children
    assert_equal 0, revision.occupancy.infants
    assert_equal 3, revision.occupancy.total_guests
  end

  # Guarantee (nested)
  test "guarantee is wrapped in Guarantee object" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_instance_of Channex::Objects::Guarantee, revision.guarantee
    assert_equal "visa", revision.guarantee.card_type
    assert_equal "4111111111111111", revision.guarantee.card_number
    assert_equal "John Doe", revision.guarantee.cardholder_name
    assert_equal "12/25", revision.guarantee.expiration_date
    assert_equal "123", revision.guarantee.cvv
  end

  # Rooms (array)
  test "rooms is an array of BookingRoom objects" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_equal 1, revision.rooms.size
    assert revision.rooms.all? { |r| r.is_a?(Channex::Objects::BookingRoom) }
  end

  test "room provides typed access to room data" do
    revision = Channex::Objects::BookingRevision.new(@data)
    room = revision.rooms.first

    assert_equal "room-1", room.ota_unique_id
    assert_equal "rt-abc", room.room_type_id
    assert_equal "rp-xyz", room.rate_plan_id
    assert_equal "2024-03-15", room.checkin_date
    assert_equal "2024-03-18", room.checkout_date
    assert_equal "450.00", room.amount
  end

  test "room provides parsed Date convenience methods" do
    revision = Channex::Objects::BookingRevision.new(@data)
    room = revision.rooms.first

    assert_equal Date.new(2024, 3, 15), room.check_in_date
    assert_equal Date.new(2024, 3, 18), room.check_out_date
    assert_equal 3, room.nights
  end

  test "room occupancy is wrapped" do
    revision = Channex::Objects::BookingRevision.new(@data)
    room = revision.rooms.first

    assert_instance_of Channex::Objects::Occupancy, room.occupancy
    assert_equal 2, room.occupancy.adults
    assert_equal 1, room.occupancy.children
    assert_equal 3, room.occupancy.total_guests
  end

  test "room guests are wrapped" do
    revision = Channex::Objects::BookingRevision.new(@data)
    room = revision.rooms.first

    assert_equal 2, room.guests.size
    assert room.guests.all? { |g| g.is_a?(Channex::Objects::Guest) }
    assert_equal "John", room.guests[0].name
    assert_equal "Doe", room.guests[0].surname
    assert_equal "John Doe", room.guests[0].full_name
  end

  test "room taxes are wrapped" do
    revision = Channex::Objects::BookingRevision.new(@data)
    room = revision.rooms.first

    assert_equal 1, room.taxes.size
    assert_instance_of Channex::Objects::Tax, room.taxes.first
    assert_equal "VAT (12%)", room.taxes.first.name
    assert_equal "75.00", room.taxes.first.total_price
    assert room.taxes.first.inclusive?
  end

  test "room days returns daily breakdown" do
    revision = Channex::Objects::BookingRevision.new(@data)
    room = revision.rooms.first

    assert_equal 3, room.days.size
    assert_equal "150.00", room.days["2024-03-15"]
  end

  test "rooms returns empty array when not present" do
    revision = Channex::Objects::BookingRevision.new({})

    assert_equal [], revision.rooms
  end

  # Services (array)
  test "services is an array of Service objects" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_equal 1, revision.services.size
    assert_instance_of Channex::Objects::Service, revision.services.first
    assert_equal "Meal", revision.services.first.type
    assert_equal "Breakfast", revision.services.first.name
    assert_equal "30.00", revision.services.first.total_price
  end

  # Backwards compatibility
  test "hash access still works" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_equal "rev-123", revision["id"]
    assert_equal "John", revision.dig("customer", "name")
  end

  test "to_h returns raw data" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_equal @data, revision.to_h
  end

  test "equality with hash works" do
    revision = Channex::Objects::BookingRevision.new(@data)

    assert_equal @data, revision
  end

  # Edge cases
  test "handles missing nested data gracefully" do
    revision = Channex::Objects::BookingRevision.new({"id" => "123"})

    assert_nil revision.customer
    assert_nil revision.occupancy
    assert_nil revision.guarantee
    assert_equal [], revision.rooms
    assert_equal [], revision.services
    assert_nil revision.amount
  end
end
