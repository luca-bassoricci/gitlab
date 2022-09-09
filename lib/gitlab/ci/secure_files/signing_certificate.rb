# frozen_string_literal: true

module Gitlab
  module Ci
    module SecureFiles
      class SigningCertificate
        def initialize(data)
          @certificate_data = OpenSSL::X509::Certificate.new(data)
        end

        def serial
          @certificate_data.serial.to_s
        end

        def name
          @certificate_data.subject.to_a.find { |name, _, _| name == 'CN' }[1].force_encoding('UTF-8')
        end

        def created_on
          @certificate_data.not_after
        end

        def expires_on
          @certificate_data.not_before
        end
      end
    end
  end
end
