# frozen_string_literal: true
module Packages
  module Rpm
    module RepositoryMetadata
      class BuildRepomdXml
        attr_reader :data

        ROOT_ATTRIBUTES = {
          xmlns: 'http://linux.duke.edu/metadata/repo',
          'xmlns:rpm': 'http://linux.duke.edu/metadata/rpm'
        }.freeze

        # Expected `data` structure
        #
        # data = {
        #   filelists: {
        #     checksum: { type: "sha256", value: "123" },
        #     location: { href: "repodata/123-filelists.xml.gz" },
        #     ...
        #   },
        #   ...
        # }
        def initialize(data)
          @data = data
        end

        def execute
          build_repomd
        end

        private

        def build_repomd
          Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
            xml.repomd(ROOT_ATTRIBUTES) do
              xml.revision Time.now.to_i
              build_data_info(xml)
            end
          end.to_xml
        end

        def build_data_info(xml)
          data.each do |filename, info|
            xml.data(type: filename) do
              build_file_info(info, xml)
            end
          end
        end

        def build_file_info(info, xml)
          info.each do |key, attributes|
            value = attributes.delete(:value)
            xml.public_send(key, value, attributes) # rubocop:disable GitlabSecurity/PublicSend
          end
        end
      end
    end
  end
end
