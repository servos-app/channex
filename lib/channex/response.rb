module Channex
  # Wraps API responses with convenient accessors
  #
  # Channex API responses follow this structure:
  # - Success: { "data": {...} } or { "data": [...], "meta": {...} }
  # - Error: { "error": {...} } or { "errors": {...} }
  #
  class Response
    attr_reader :status, :headers, :raw_body, :body

    def initialize(http_response)
      @status = http_response.code.to_i
      @headers = http_response.to_hash
      @raw_body = http_response.body
      @body = parse_body(http_response.body)
    end

    def success?
      status >= 200 && status < 300
    end

    def data
      body["data"]
    end

    def meta
      body["meta"] || {}
    end

    # Returns error information from the response
    #
    # Channex API can return errors in two formats:
    # - { "error": { "message": "...", "code": "..." } }
    # - { "errors": { "code": "...", "title": "..." } }
    #
    # @return [Hash, nil] Error information or nil if no error
    def error
      body["error"] || body["errors"]
    end

    # Returns warnings from the response meta
    #
    # ARI updates can return partial success with warnings for invalid values.
    #
    # @return [Array] Array of warning objects
    def warnings
      meta["warnings"] || []
    end

    def pagination
      @pagination ||= Pagination.new(meta)
    end

    private

    def parse_body(body)
      return {} if body.nil? || body.empty?

      JSON.parse(body)
    rescue JSON::ParserError
      {"raw" => body}
    end
  end

  # Pagination information from API responses
  class Pagination
    attr_reader :page, :limit, :total, :order

    def initialize(meta)
      @page = meta["page"]
      @limit = meta["limit"]
      @total = meta["total"]
      @order = meta["order"]
    end

    def total_pages
      return nil unless total && limit && limit > 0

      (total.to_f / limit).ceil
    end

    def next_page
      return nil unless page && total_pages

      (page < total_pages) ? page + 1 : nil
    end

    def prev_page
      return nil unless page

      (page > 1) ? page - 1 : nil
    end

    def has_next?
      !next_page.nil?
    end

    def has_prev?
      !prev_page.nil?
    end
  end
end
