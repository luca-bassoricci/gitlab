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
          p7 = OpenSSL::PKCS7.new(@filedata)
          p7.verify(nil, OpenSSL::X509::Store.new, nil, OpenSSL::PKCS7::NOVERIFY)
          p7.data
        rescue StandardError => e
          @error = e
          nil
        end

        def value_for(key)
          properties[key]
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

        # Detect is development type of mobileprovision
        #
        # related link: https://stackoverflow.com/questions/1003066/what-does-get-task-allow-do-in-xcode
        def development?
          case platform.downcase.to_sym
          when :ios
            entitlements['get-task-allow'] == true
          when :macos
            !devices.nil?
          else
            raise Error, "Not implement with platform: #{platform}"
          end
        end

        # Detect app store type
        #
        # related link: https://developer.apple.com/library/archive/qa/qa1830/_index.html
        def appstore?
          case platform.downcase.to_sym
          when :ios
            !development? && entitlements.key?('beta-reports-active')
          when :macos
            !development?
          else
            raise Error, "Not implement with platform: #{platform}"
          end
        end

        def adhoc?
          return false if platform == :macos # macOS no need adhoc

          !development? && !devices.nil?
        end

        def enterprise?
          return false if platform == :macos # macOS no need adhoc

          !development? && !adhoc? && !appstore?
        end
        alias_method :inhouse?, :enterprise?

        def developer_certificates
          certificates = value_for('DeveloperCertificates')
          return if certificates.empty?

          certificates.each_with_object([]) do |cert, obj|
            obj << SigningCertificate.new(cert)
          end
        end

        def properties
          list = CFPropertyList::List.new(data: decoded_plist).value
          @properties = CFPropertyList.native_types(list)
        rescue CFFormatError
          @properties = nil
        end
      end
    end
  end
end
