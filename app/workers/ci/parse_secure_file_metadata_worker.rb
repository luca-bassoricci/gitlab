# frozen_string_literal: true

module Ci
  class ParseSecureFileMetadataWorker
    include ::ApplicationWorker

    urgency :low
    idempotent!

    def perform(secure_file_id)
      ::Ci::SecureFile.find(secure_file_id).try(&:update_metadata)
    end
  end
end
