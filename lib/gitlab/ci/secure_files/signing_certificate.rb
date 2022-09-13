# frozen_string_literal: true

module Gitlab
  module Ci
    module SecureFiles
      class SigningCertificate
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

        def internal_attributes
          return [] unless certificate_data

          [
            {
              name: 'Serial',
              value: serial
            },
            {
              name: 'Name',
              value: name
            },
            {
              name: 'Expires on',
              value: expires_on
            }
          ]
        end

        def serial
          return unless certificate_data

          certificate_data.serial.to_s
        end

        def name
          certificate_data.subject.to_a.find { |name, _, _| name == 'CN' }[1].force_encoding('UTF-8')
        end

        def created_on
          certificate_data.not_after
        end

        def expires_on
          certificate_data.not_before
        end
      end
    end
  end
end
