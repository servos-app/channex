module Channex
  module Resources
    # Photos API resource
    #
    # Photos are associated with Properties and optionally with Room Types.
    # Position 0 is used as the cover photo.
    #
    # @example List photos for a property
    #   client.photos.list(property_id: "property-uuid")
    #
    # @example Create a photo from URL
    #   client.photos.create(
    #     property_id: "property-uuid",
    #     url: "https://example.com/photo.jpg",
    #     position: 0,
    #     description: "Hotel Lobby",
    #     kind: "photo"
    #   )
    #
    # @example Upload a photo file then create it
    #   # Step 1: Upload the file to get a temporary URL
    #   upload_response = client.photos.upload("/path/to/photo.jpg")
    #   temp_url = upload_response.body["url"]
    #
    #   # Step 2: Create the photo using the temporary URL
    #   client.photos.create(
    #     property_id: "property-uuid",
    #     url: temp_url,
    #     position: 0
    #   )
    #
    # @see https://docs.channex.io/api-v.1-documentation/photos-collection
    #
    class Photos < Resource
      KINDS = %w[photo ad menu].freeze

      # Upload a photo file and get a temporary URL
      #
      # This uploads the file to Channex's servers and returns a temporary URL
      # that can then be used with the create method.
      #
      # @param file_path [String] Path to the photo file
      # @return [Response] Response with "url" in body containing temporary URL
      #
      # @example
      #   response = client.photos.upload("/path/to/photo.jpg")
      #   temp_url = response.body["url"]
      #   # => "https://ams3.digitaloceanspaces.com/temporaryphotos/..."
      def upload(file_path)
        uri = URI("#{client.configuration.api_url}#{resource_path}/upload")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.read_timeout = client.configuration.timeout
        http.open_timeout = client.configuration.open_timeout

        request = Net::HTTP::Post.new(uri)
        request["user-api-key"] = client.api_key

        file = File.open(file_path, "rb")
        filename = File.basename(file_path)
        boundary = "----RubyMultipartPost#{rand(1000000)}"

        request["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
        request.body = build_multipart_body(file, filename, boundary)
        file.close

        response = http.request(request)
        Response.new(response)
      end

      # Reorder photos
      #
      # @param photos [Array<Hash>] Array of { id: "uuid", position: 0 }
      # @return [Response]
      def reorder(photos)
        client.post("#{resource_path}/reorder", body: {photos: photos})
      end

      protected

      def resource_path
        "/photos"
      end

      def filter_keys
        %i[property_id room_type_id]
      end

      private

      def build_multipart_body(file, filename, boundary)
        body = []
        body << "--#{boundary}\r\n"
        body << "Content-Disposition: form-data; name=\"photo\"; filename=\"#{filename}\"\r\n"
        body << "Content-Type: #{mime_type_for(filename)}\r\n\r\n"
        body << file.read
        body << "\r\n--#{boundary}--\r\n"
        body.join
      end

      def mime_type_for(filename)
        case File.extname(filename).downcase
        when ".jpg", ".jpeg"
          "image/jpeg"
        when ".png"
          "image/png"
        when ".gif"
          "image/gif"
        when ".webp"
          "image/webp"
        else
          "application/octet-stream"
        end
      end
    end
  end
end
