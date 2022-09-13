# frozen_string_literal: true

module Gitlab
  module Ci
    module SecureFiles
      class Mobileprovision
        attr_reader :error

        def initialize(filedata)
          @filedata = filedata
        end

        def decoded_plist
          @decoded_plist ||= begin
            p7 = OpenSSL::PKCS7.new(@filedata)
            p7.verify(nil, OpenSSL::X509::Store.new, nil, OpenSSL::PKCS7::NOVERIFY)
            p7.data
          rescue StandardError => e
            @error = e
            nil
          end
        end

        def properties
          @properties ||= begin
            list = CFPropertyList::List.new(data: decoded_plist).value
            CFPropertyList.native_types(list)
          rescue CFFormatError
            nil
          end
        end

        def value_for(key)
          properties[key]
        end

        def internal_attributes
          [
            {
              name: 'UUID',
              value: uuid
            },
            {
              name: 'Expires on',
              value: expires_on
            },
            {
              name: 'Platforms',
              value: platforms.join(',')
            },
            {
              name: 'Team',
              value: "#{team_name} (#{team_identifier.first})"
            },
            {
              name: 'App',
              value: "#{app_name} (#{name})"
            },
            {
              name: 'Certificates',
              value: developer_certificates.map(&:serial).join(',')
            }
          ]
        end

        def uuid
          value_for('UUID')
        end

        def name
          value_for('Name')
        end

        def app_name
          value_for('AppIDName')
        end

        def devices
          value_for('ProvisionedDevices')
        end

        def team_identifier
          value_for('TeamIdentifier')
        end

        def team_name
          value_for('TeamName')
        end

        def profile_name
          value_for('Name')
        end

        def created_on
          value_for('CreationDate')
        end

        def expires_on
          value_for('ExpirationDate')
        end

        def entitlements
          value_for('Entitlements')
        end

        def platforms
          return unless platforms = value_for('Platform')

          platforms.map do |v|
            v = 'macOS' if v == 'OSX'
            v.downcase.to_sym
          end
        end

        def platform
          platforms[0]
        end

        def developer_certificates
          certificates = value_for('DeveloperCertificates')
          return if certificates.empty?

          certificates.each_with_object([]) do |cert, obj|
            obj << SigningCertificate.new(cert)
          end
        end
      end
    end
  end
end
