# frozen_string_literal: true

module Gitlab
  module X509
    class Certificate
      CERT_REGEX = /-----BEGIN CERTIFICATE-----(?:.|\n)+?-----END CERTIFICATE-----/.freeze

      attr_reader :key, :cert, :ca_certs

      def key_string
        key.to_s
      end

      def cert_string
        cert.to_pem
      end

      def ca_certs_string
        ca_certs.map(&:to_pem).join('\n') unless ca_certs.blank?
      end

      def self.from_strings(key_string, cert_string, ca_certs_string = nil)
        key = OpenSSL::PKey::RSA.new(key_string)
        cert = OpenSSL::X509::Certificate.new(cert_string)
        ca_certs = load_ca_certs_bundle(ca_certs_string)

        new(key, cert, ca_certs)
      end

      def self.from_files(key_path, cert_path, ca_certs_path = nil)
        ca_certs_string = File.read(ca_certs_path) if ca_certs_path

        from_strings(File.read(key_path), File.read(cert_path), ca_certs_string)
      end

      # Returns all top-level, readable files in the default CA cert directory
      def self.ca_certs_paths
        cert_paths = Dir["#{OpenSSL::X509::DEFAULT_CERT_DIR}/*"].select do |path|
          !File.directory?(path) && File.readable?(path)
        end
        cert_paths << OpenSSL::X509::DEFAULT_CERT_FILE if File.exist? OpenSSL::X509::DEFAULT_CERT_FILE
        cert_paths
      end

      # Returns a concatenated array of Strings, each being a PEM-coded CA certificate.
      def self.ca_certs_bundle
        return @certs if @certs

        @certs = ca_certs_paths.flat_map do |cert_file|
          load_ca_certs_bundle(File.read(cert_file))
        rescue OpenSSL::OpenSSLError => e
          Gitlab::ErrorTracking.track_and_raise_for_dev_exception(e, cert_file: cert_file)
        end.uniq.join("\n")
      end

      # Returns an array of OpenSSL::X509::Certificate objects, empty array if none found
      #
      # Ruby OpenSSL::X509::Certificate.new will only load the first
      # certificate if a bundle is presented, this allows to parse multiple certs
      # in the same file
      def self.load_ca_certs_bundle(ca_certs_string)
        return [] unless ca_certs_string

        ca_certs_string.scan(CERT_REGEX).map do |ca_cert_string|
          OpenSSL::X509::Certificate.new(ca_cert_string)
        end
      end

      def initialize(key, cert, ca_certs = nil)
        @key = key
        @cert = cert
        @ca_certs = ca_certs
      end
    end
  end
end
