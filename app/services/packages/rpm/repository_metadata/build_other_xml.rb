# frozen_string_literal: true
module Packages
  module Rpm
    module RepositoryMetadata
      class BuildOtherXml
        ROOT_TAG = 'otherdata'
        ROOT_ATTRIBUTES = {
          xmlns: 'http://linux.duke.edu/metadata/other',
          packages: '0'
        }.freeze

        class << self
          def execute(data)
            builder = Nokogiri::XML::Builder.new do |xml|
              xml.package(pkgid: data[:pkgid], name: data[:name], arch: data[:arch]) do
                xml.version epoch: data[:epoch], ver: data[:version], rel: data[:release]
                build_changelog_nodes(xml, data)
              end
            end

            Nokogiri::XML(builder.to_xml).at('package')
          end

          def build_changelog_nodes(xml, data)
            data[:changelogs].each do |changelog|
              xml.changelog changelog[:changelogtext], date: changelog[:changelogtime]
            end
          end
        end
      end
    end
  end
end
