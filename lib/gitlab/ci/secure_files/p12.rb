# frozen_string_literal: true

module Gitlab
  module Ci
    module SecureFiles
      class P12
        attr_reader :error

        def initialize(filedata, password = nil)
          @filedata = filedata
          @password = password
        end

        def certificate_data
          @certificate_data ||= begin
            OpenSSL::PKCS12.new(@filedata, @password).certificate
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
            serial: certificate_data.serial.to_s,
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
