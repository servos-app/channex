require "test_helper"

class Channex::ObjectTest < ActiveSupport::TestCase
  test "provides hash-like access with string keys" do
    obj = Channex::Object.new({"id" => "123", "name" => "Test"})

    assert_equal "123", obj["id"]
    assert_equal "Test", obj["name"]
    assert_nil obj["missing"]
  end

  test "provides hash-like access with symbol keys (converts to string)" do
    obj = Channex::Object.new({"id" => "123"})

    assert_equal "123", obj[:id]
  end

  test "dig works for nested data" do
    obj = Channex::Object.new({"customer" => {"name" => "John", "address" => {"city" => "London"}}})

    assert_equal "John", obj.dig("customer", "name")
    assert_equal "London", obj.dig("customer", "address", "city")
    assert_nil obj.dig("customer", "missing")
  end

  test "dig works with symbol keys (converts to strings)" do
    obj = Channex::Object.new({"customer" => {"name" => "John"}})

    assert_equal "John", obj.dig(:customer, :name)
  end

  test "to_h returns a copy of raw data" do
    data = {"id" => "123"}
    obj = Channex::Object.new(data)

    result = obj.to_h
    assert_equal data, result
    assert_not_same data, result  # should be a copy
  end

  test "to_hash is aliased to to_h" do
    obj = Channex::Object.new({"id" => "123"})

    assert_equal obj.to_h, obj.to_hash
  end

  test "to_json serializes data" do
    obj = Channex::Object.new({"id" => "123", "name" => "Test"})

    parsed = JSON.parse(obj.to_json)
    assert_equal({"id" => "123", "name" => "Test"}, parsed)
  end

  test "keys returns all keys" do
    obj = Channex::Object.new({"a" => 1, "b" => 2, "c" => 3})

    assert_equal ["a", "b", "c"], obj.keys
  end

  test "values returns all values" do
    obj = Channex::Object.new({"a" => 1, "b" => 2})

    assert_equal [1, 2], obj.values
  end

  test "key? checks for key existence" do
    obj = Channex::Object.new({"exists" => "yes"})

    assert obj.key?("exists")
    assert obj.key?(:exists)  # symbol conversion
    assert_not obj.key?("missing")
  end

  test "has_key? is aliased to key?" do
    obj = Channex::Object.new({"exists" => "yes"})

    assert obj.has_key?("exists")
  end

  test "fetch with existing key returns value" do
    obj = Channex::Object.new({"id" => "123"})

    assert_equal "123", obj.fetch("id")
  end

  test "fetch with missing key and default returns default" do
    obj = Channex::Object.new({})

    assert_equal "default", obj.fetch("missing", "default")
  end

  test "fetch with missing key and block returns block result" do
    obj = Channex::Object.new({})

    assert_equal "computed", obj.fetch("missing") { "computed" }
  end

  test "fetch with missing key and no default raises KeyError" do
    obj = Channex::Object.new({})

    assert_raises(KeyError) { obj.fetch("missing") }
  end

  test "each iterates over key/value pairs" do
    obj = Channex::Object.new({"a" => 1, "b" => 2})
    collected = []

    obj.each { |k, v| collected << [k, v] }

    assert_equal [["a", 1], ["b", 2]], collected
  end

  test "is enumerable" do
    obj = Channex::Object.new({"a" => 1, "b" => 2})

    assert_equal [["a", 1], ["b", 2]], obj.to_a
  end

  test "equality with hash" do
    data = {"id" => "123"}
    obj = Channex::Object.new(data)

    assert_equal data, obj
    assert obj == data
  end

  test "equality with another Object" do
    obj1 = Channex::Object.new({"id" => "123"})
    obj2 = Channex::Object.new({"id" => "123"})

    assert_equal obj1, obj2
  end

  test "inequality with different data" do
    obj1 = Channex::Object.new({"id" => "123"})
    obj2 = Channex::Object.new({"id" => "456"})

    assert_not_equal obj1, obj2
  end

  test "construct_from returns nil for nil data" do
    assert_nil Channex::Object.construct_from(nil)
  end

  test "construct_from creates object from data" do
    obj = Channex::Object.construct_from({"id" => "123"})

    assert_instance_of Channex::Object, obj
    assert_equal "123", obj["id"]
  end

  test "handles non-hash input gracefully" do
    obj = Channex::Object.new("invalid")

    assert_equal({}, obj.to_h)
  end

  test "inspect shows class name and data" do
    obj = Channex::Object.new({"id" => "123"})

    assert_match(/Channex::Object/, obj.inspect)
    assert_match(/id/, obj.inspect)
    assert_match(/123/, obj.inspect)
  end
end

class Channex::ObjectAttributeTest < ActiveSupport::TestCase
  # Test subclass with defined attributes
  class TestObject < Channex::Object
    attribute :id
    attribute :name
    attribute :email, key: "mail"
  end

  test "attribute defines accessor method" do
    obj = TestObject.new({"id" => "123", "name" => "Test"})

    assert_equal "123", obj.id
    assert_equal "Test", obj.name
  end

  test "attribute with custom key accesses different hash key" do
    obj = TestObject.new({"mail" => "test@example.com"})

    assert_equal "test@example.com", obj.email
  end

  test "attribute returns nil for missing data" do
    obj = TestObject.new({})

    assert_nil obj.id
    assert_nil obj.name
  end

  test "hash access still works alongside attributes" do
    obj = TestObject.new({"id" => "123", "other" => "value"})

    assert_equal "123", obj.id       # attribute
    assert_equal "123", obj["id"]    # hash access
    assert_equal "value", obj["other"]  # hash access for non-attribute
  end
end

class Channex::ObjectNestedAttributeTest < ActiveSupport::TestCase
  class NestedObject < Channex::Object
    attribute :value
  end

  class ParentObject < Channex::Object
    attribute :id
    attribute :nested, type: NestedObject
  end

  test "nested attribute wraps in typed object" do
    obj = ParentObject.new({"id" => "123", "nested" => {"value" => "inner"}})

    assert_instance_of NestedObject, obj.nested
    assert_equal "inner", obj.nested.value
  end

  test "nested attribute returns nil when data is nil" do
    obj = ParentObject.new({"id" => "123"})

    assert_nil obj.nested
  end

  test "nested object is memoized" do
    obj = ParentObject.new({"nested" => {"value" => "inner"}})

    assert_same obj.nested, obj.nested
  end
end

class Channex::ObjectArrayAttributeTest < ActiveSupport::TestCase
  class ItemObject < Channex::Object
    attribute :name
  end

  class ContainerObject < Channex::Object
    attribute :id
    array_attribute :items, type: ItemObject
  end

  test "array_attribute wraps each element in typed object" do
    obj = ContainerObject.new({
      "id" => "123",
      "items" => [
        {"name" => "first"},
        {"name" => "second"}
      ]
    })

    assert_equal 2, obj.items.size
    assert obj.items.all? { |item| item.is_a?(ItemObject) }
    assert_equal "first", obj.items[0].name
    assert_equal "second", obj.items[1].name
  end

  test "array_attribute returns empty array when data is nil" do
    obj = ContainerObject.new({"id" => "123"})

    assert_equal [], obj.items
  end

  test "array_attribute returns empty array when data is missing" do
    obj = ContainerObject.new({})

    assert_equal [], obj.items
  end

  test "array is memoized" do
    obj = ContainerObject.new({"items" => [{"name" => "test"}]})

    assert_same obj.items, obj.items
  end
end
