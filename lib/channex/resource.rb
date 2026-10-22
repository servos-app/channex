module Channex
  # Base class for API resources
  #
  # Provides common CRUD operations and pagination support.
  # Subclasses should define their resource path and customize
  # behavior as needed.
  #
  class Resource
    attr_reader :client

    def initialize(client)
      @client = client
    end

    # List all resources with optional filtering and pagination
    #
    # @param page [Integer] Page number (starts at 1)
    # @param limit [Integer] Number of results per page (max 100)
    # @param filter [Hash] Filter parameters
    # @param order [Hash] Ordering parameters (e.g., { inserted_at: :asc })
    # @param params [Hash] Keywords named by #filter_keys join the filter; the rest are sent as top-level params
    # @return [Response]
    def list(page: nil, limit: nil, filter: {}, order: {}, **params)
      named_filters = params.extract!(*filter_keys).compact
      filter = filter.merge(named_filters)
      client.get(resource_path, params: query_params(page:, limit:, filter:, order:, **params))
    end

    # Retrieve all resources using automatic pagination
    #
    # @yield [data] Yields each page of data
    # @yieldparam data [Array] Array of resource data from the page
    # @return [Array] All resources if no block given
    def list_all(filter: {}, order: {}, **params)
      all_data = []
      page = 1
      limit = 100

      loop do
        response = list(page: page, limit: limit, filter: filter, order: order, **params)
        data = response.data || []

        if block_given?
          yield data
        else
          all_data.concat(data)
        end

        break unless response.pagination.has_next?

        page += 1
      end

      all_data unless block_given?
    end

    # Retrieve a single resource by ID
    #
    # @param id [String] Resource UUID
    # @return [Response]
    def retrieve(id)
      client.get("#{resource_path}/#{id}")
    end

    # Create a new resource
    #
    # @param attributes [Hash] Resource attributes
    # @return [Response]
    def create(attributes)
      client.post(resource_path, body: wrap_attributes(attributes))
    end

    # Update an existing resource
    #
    # @param id [String] Resource UUID
    # @param attributes [Hash] Resource attributes to update
    # @return [Response]
    def update(id, attributes)
      client.put("#{resource_path}/#{id}", body: wrap_attributes(attributes))
    end

    # Delete a resource
    #
    # @param id [String] Resource UUID
    # @return [Response]
    def delete(id)
      client.delete("#{resource_path}/#{id}")
    end

    protected

    # Build the query string Channex expects: pagination, filter and order are
    # each nested one level deep (e.g. `pagination[page]=2`). Shared with
    # resources whose collections hang off another resource's path.
    #
    # @return [Hash]
    def query_params(page: nil, limit: nil, filter: {}, order: {}, **params)
      query = params.dup

      pagination = {}
      pagination[:page] = page if page
      pagination[:limit] = limit if limit
      query[:pagination] = pagination unless pagination.empty?

      query[:filter] = filter unless filter.empty?
      query[:order] = order unless order.empty?

      query
    end

    # Override in subclasses to define the API path
    def resource_path
      raise NotImplementedError, "Subclass must implement #resource_path"
    end

    # Override to change how attributes are wrapped for create/update
    def wrap_attributes(attributes)
      {resource_name => attributes}
    end

    def resource_name
      self.class.name.demodulize.underscore.singularize
    end

    # Override to name the keywords #list sends to Channex as filters
    def filter_keys
      []
    end
  end
end
