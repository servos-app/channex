require "test_helper"

class Channex::Objects::GuaranteeTest < ActiveSupport::TestCase
  setup do
    @data = {
      "card_number" => "4111111111111111",
      "card_type" => "visa",
      "cardholder_name" => "John Doe",
      "cvv" => "123",
      "expiration_date" => "12/25"
    }
  end

  # Core attributes
  test "provides typed access to card_number" do
    guarantee = Channex::Objects::Guarantee.new(@data)

    assert_equal "4111111111111111", guarantee.card_number
  end

  test "provides typed access to card_type" do
    guarantee = Channex::Objects::Guarantee.new(@data)

    assert_equal "visa", guarantee.card_type
  end

  test "provides typed access to cardholder_name" do
    guarantee = Channex::Objects::Guarantee.new(@data)

    assert_equal "John Doe", guarantee.cardholder_name
  end

  test "provides typed access to cvv" do
    guarantee = Channex::Objects::Guarantee.new(@data)

    assert_equal "123", guarantee.cvv
  end

  test "provides typed access to expiration_date" do
    guarantee = Channex::Objects::Guarantee.new(@data)

    assert_equal "12/25", guarantee.expiration_date
  end

  # Different card types
  test "handles visa card type" do
    guarantee = Channex::Objects::Guarantee.new(@data.merge("card_type" => "visa"))

    assert_equal "visa", guarantee.card_type
  end

  test "handles mastercard card type" do
    guarantee = Channex::Objects::Guarantee.new(@data.merge("card_type" => "mastercard"))

    assert_equal "mastercard", guarantee.card_type
  end

  test "handles amex card type" do
    guarantee = Channex::Objects::Guarantee.new(@data.merge("card_type" => "amex"))

    assert_equal "amex", guarantee.card_type
  end

  test "handles discover card type" do
    guarantee = Channex::Objects::Guarantee.new(@data.merge("card_type" => "discover"))

    assert_equal "discover", guarantee.card_type
  end

  # Hash access (inherited from Channex::Object)
  test "hash access still works" do
    guarantee = Channex::Objects::Guarantee.new(@data)

    assert_equal "4111111111111111", guarantee["card_number"]
    assert_equal "visa", guarantee["card_type"]
  end

  test "to_h returns raw data" do
    guarantee = Channex::Objects::Guarantee.new(@data)

    assert_equal @data, guarantee.to_h
  end

  # Edge cases
  test "handles missing data gracefully" do
    guarantee = Channex::Objects::Guarantee.new({})

    assert_nil guarantee.card_number
    assert_nil guarantee.card_type
    assert_nil guarantee.cardholder_name
    assert_nil guarantee.cvv
    assert_nil guarantee.expiration_date
  end

  test "handles partial card data" do
    guarantee = Channex::Objects::Guarantee.new({
      "card_type" => "visa",
      "cardholder_name" => "John Doe"
    })

    assert_equal "visa", guarantee.card_type
    assert_equal "John Doe", guarantee.cardholder_name
    assert_nil guarantee.card_number
    assert_nil guarantee.cvv
    assert_nil guarantee.expiration_date
  end

  test "handles masked card number" do
    guarantee = Channex::Objects::Guarantee.new(@data.merge("card_number" => "************1111"))

    assert_equal "************1111", guarantee.card_number
  end

  test "handles different expiration date formats" do
    formats = ["12/25", "12/2025", "2025-12"]

    formats.each do |format|
      guarantee = Channex::Objects::Guarantee.new(@data.merge("expiration_date" => format))
      assert_equal format, guarantee.expiration_date
    end
  end

  test "handles 4-digit cvv for amex" do
    guarantee = Channex::Objects::Guarantee.new(@data.merge(
      "card_type" => "amex",
      "cvv" => "1234"
    ))

    assert_equal "1234", guarantee.cvv
  end
end
