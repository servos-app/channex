module Channex
  module Resources
    # Attachments API resource
    #
    # Sending a file to a guest is two calls: upload it here, then pass the
    # returned id to {MessageThreads#send_message} or {Messages#send_message}.
    #
    # @example Send a photo of the directions
    #   attachment = client.attachments.create(
    #     file: Base64.strict_encode64(File.binread("directions.jpeg")),
    #     file_name: "directions.jpeg",
    #     file_type: "image/jpeg"
    #   )
    #   client.message_threads.send_message("thread-uuid", attachment_id: attachment.data["id"])
    #
    # @see https://docs.channex.io/api-v.1-documentation/messages-collection
    #
    class Attachments < Resource
      # Upload an attachment
      #
      # @param file [String] Base64-encoded file contents
      # @param file_name [String] File name, e.g. "photo.jpeg"
      # @param file_type [String] MIME type, e.g. "image/jpeg"
      # @return [Response]
      def create(file:, file_name:, file_type:)
        client.post(resource_path, body: {attachment: {file:, file_name:, file_type:}})
      end

      protected

      def resource_path
        "/attachments"
      end
    end
  end
end
