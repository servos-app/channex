module Channex
  # Base class for typed API response objects
  #
  # Provides typed accessor methods while maintaining hash compatibility
  # for backwards compatibility and easy data exploration.
  #
  # @example Basic usage
  #   revision = Channex::Objects::BookingRevision.new(data)
  #   revision.id                      # => "uuid" (typed accessor)
  #   revision["id"]                   # => "uuid" (hash access)
  #   revision.dig("customer", "name") # => "John"
  #   revision.to_h                    # => {"id" => "uuid", ...}
  #
  # @example Defining attributes in subclasses
  #   class BookingRevision < Channex::Object
  #     attribute :id
  #     attribute :customer, type: Customer
  #     array_attribute :rooms, type: BookingRoom
  #   end
  #
  class Object
    include Enumerable

    class << self
      # Define a typed attribute with optional type coercion
      #
      # @param name [Symbol] Attribute name (becomes the method name)
      # @param type [Class, nil] Optional class for nested object wrapping
      # @param key [String, nil] Override the hash key (defaults to name.to_s)
      #
      # @example Simple attribute
      #   attribute :id
      #
      # @example Nested object
      #   attribute :customer, type: Customer
      #
      # @example Different key name
      #   attribute :email, key: "mail"
      #
      def attribute(name, type: nil, key: nil)
        key ||= name.to_s

        attributes[name] = {key: key, type: type}

        define_method(name) do
          value = @data[key]
          return nil if value.nil?

          if type
            @wrapped_values[name] ||= wrap_value(value, type)
          else
            value
          end
        end
      end

      # Define an array attribute with typed elements
      #
      # @param name [Symbol] Attribute name
      # @param type [Class] Class for array element wrapping
      # @param key [String, nil] Override the hash key
      #
      # @example
      #   array_attribute :rooms, type: BookingRoom
      #
      def array_attribute(name, type:, key: nil)
        key ||= name.to_s

        attributes[name] = {key: key, type: type, array: true}

        define_method(name) do
          @wrapped_values[name] ||= begin
            raw = @data[key] || []
            raw.map { |item| wrap_value(item, type) }
          end
        end
      end

      # Registry of defined attributes for this class
      # @return [Hash]
      def attributes
        @attributes ||= {}
      end

      # Construct an object from raw API data
      #
      # @param data [Hash, nil] Raw API response data
      # @return [Object, nil] Wrapped object or nil if data is nil
      def construct_from(data)
        return nil if data.nil?
        new(data)
      end
    end

    # @param data [Hash] Raw API response data
    def initialize(data)
      @data = data.is_a?(Hash) ? data : {}
      @wrapped_values = {}
    end

    # Hash-like access for backwards compatibility
    #
    # @param key [String, Symbol] Hash key
    # @return [Object, nil] Value at key
    def [](key)
      @data[key.to_s]
    end

    # Deep access for nested data
    #
    # @param keys [Array<String, Symbol>] Path of keys
    # @return [Object, nil] Value at path
    def dig(*keys)
      @data.dig(*keys.map(&:to_s))
    end

    # Return the underlying hash data
    # @return [Hash]
    def to_h
      @data.dup
    end
    alias_method :to_hash, :to_h

    # JSON serialization
    # @return [String]
    def to_json(*args)
      @data.to_json(*args)
    end

    # Rails JSON serialization support
    # @return [Hash]
    def as_json(*args)
      @data.as_json(*args)
    end

    # Enumerable support - iterate over key/value pairs
    def each(&block)
      @data.each(&block)
    end

    # @return [Array<String>] All keys in the data
    def keys
      @data.keys
    end

    # @return [Array] All values in the data
    def values
      @data.values
    end

    # Check if a key exists
    # @param key [String, Symbol]
    # @return [Boolean]
    def key?(key)
      @data.key?(key.to_s)
    end
    alias_method :has_key?, :key?

    # Fetch with default value support
    # @param key [String, Symbol]
    # @return [Object]
    def fetch(key, *args, &block)
      @data.fetch(key.to_s, *args, &block)
    end

    # Debug representation
    # @return [String]
    def inspect
      "#<#{self.class.name} #{@data.inspect}>"
    end

    # @return [String]
    def to_s
      inspect
    end

    # Equality based on underlying data
    # @param other [Object, Hash]
    # @return [Boolean]
    def ==(other)
      case other
      when Channex::Object
        @data == other.to_h
      when Hash
        @data == other
      else
        false
      end
    end

    private

    def wrap_value(value, type)
      return nil if value.nil?

      if type.respond_to?(:construct_from)
        type.construct_from(value)
      elsif type.is_a?(Class) && type < Channex::Object
        type.new(value)
      else
        value
      end
    end
  end
end
