# frozen_string_literal: true

module Gitlab
  module Ci
    module SecureFiles
      class Cer
        attr_reader :error

        def initialize(filedata)
          @filedata = filedata
        end

        def certificate_data
          @certificate_data ||= begin
            OpenSSL::X509::Certificate.new(@filedata)
          rescue StandardError => e
            @error = e
            nil
          end
        end

        def metadata
          return {} unless certificate_data

          {
            issuer: X509Name.parse(certificate_data.issuer),
            subject: X509Name.parse(certificate_data.subject),
            id: certificate_data.serial.to_s,
            expires_at: certificate_data.not_before
          }
        end

        def serial
          certificate_data.serial.to_s
        end

        def expires_at
          certificate_data.not_before
        end
      end
    end
  end
end
