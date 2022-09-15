# frozen_string_literal: true

module Gitlab
  module Ci
    module SecureFiles
      class X509Name
        KEYS = {
          'C' => 'Country Name',
          'O' => 'Organization Name',
          'OU' => 'Organization Unit',
          'CN' => 'Common Name',
          'UID' => 'User Id'
        }.freeze

        def self.parse(x509_name)
          x509_name.to_utf8.split(',').to_h { |a| a.split('=') }
        rescue StandardError
          {}
        end
      end
    end
  end
end
