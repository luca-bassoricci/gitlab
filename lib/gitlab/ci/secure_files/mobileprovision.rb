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

        def metadata
          {
            id: properties['UUID'],
            expires_at: properties['ExpirationDate'],
            platforms: properties["Platform"],
            team_name: properties['TeamName'],
            team_id: properties['TeamIdentifier'],
            app_name: properties['AppIDName'],
            app_id: properties['Name'],
            app_id_prefix: properties['ApplicationIdentifierPrefix'],
            xcode_managed: properties['IsXcodeManaged'],
            entitlements: properties['Entitlements'],
            devices: properties['ProvisionedDevices'],
            certificate_ids: certificate_ids
          }
        end

        def expires_at
          properties['ExpirationDate']
        end

        def certificate_ids
          return [] if developer_certificates.empty?

          developer_certificates.map(&:serial)
        end

        def developer_certificates
          certificates = properties['DeveloperCertificates']
          return if certificates.empty?

          certs = []
          certificates.each_with_object([]) do |cert, obj|
            certs << Cer.new(cert)
          end

          certs
        end
      end
    end
  end
end
