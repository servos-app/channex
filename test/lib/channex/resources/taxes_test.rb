require "test_helper"

class Channex::Resources::TaxesTest < ActiveSupport::TestCase
  setup do
    @client = mock("client")
    @taxes = Channex::Resources::Taxes.new(@client)
  end

  test "LOGIC_TYPES constant includes all logic types" do
    expected = %w[percent per_room per_room_per_night per_person per_person_per_night per_night per_booking]
    assert_equal expected, Channex::Resources::Taxes::LOGIC_TYPES
  end

  test "TAX_TYPES constant includes all tax types" do
    expected = %w[tax fee city\ tax]
    assert_equal expected, Channex::Resources::Taxes::TAX_TYPES
  end

  test "list with property_id filter" do
    response = mock("response")

    @client.expects(:get).with("/taxes", params: {filter: {property_id: "prop-123"}}).returns(response)

    @taxes.list(property_id: "prop-123")
  end

  test "create wraps attributes in tax key" do
    response = mock("response")
    attributes = {
      property_id: "prop-123",
      title: "VAT",
      logic: "percent",
      type: "tax",
      rate: 25.0,
      is_inclusive: false
    }

    @client.expects(:post).with("/taxes", body: {tax: attributes}).returns(response)

    @taxes.create(attributes)
  end

  test "update wraps attributes in tax key" do
    response = mock("response")

    @client.expects(:put).with("/taxes/tax-123", body: {tax: {rate: 21.0}}).returns(response)

    @taxes.update("tax-123", rate: 21.0)
  end
end
