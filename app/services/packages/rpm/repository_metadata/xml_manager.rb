# frozen_string_literal: true
module Packages
  module Rpm
    module RepositoryMetadata
      class XmlManager
        BUILDERS = Hash.new(::Packages::Rpm::RepositoryMetadata::NotImplementedXml).update(
          other: ::Packages::Rpm::RepositoryMetadata::BuildOtherXml,
          primary: ::Packages::Rpm::RepositoryMetadata::BuildPrimaryXml
        )

        def initialize(filename:, xml: nil, data: {})
          @xml = Nokogiri::XML(xml) if xml.present?
          @data = data
          @builder_class = BUILDERS[filename]
        end

        def execute
          return build_empty_structure if xml.blank?

          remove_existed_package
          update_xml_document
          update_package_count
          xml.to_xml
        end

        private

        attr_reader :xml, :data, :builder_class

        def build_empty_structure
          Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
            xml.method_missing(builder_class::ROOT_TAG, builder_class::ROOT_ATTRIBUTES)
          end.to_xml
        end

        def update_xml_document
          # Add to the root xml element a new package metadata node
          xml.at(builder_class::ROOT_TAG).add_child(builder_class.execute(data))
        end

        def update_package_count
          packages_count = xml.css("//#{builder_class::ROOT_TAG}/package").count

          xml.at(builder_class::ROOT_TAG).attributes["packages"].value = packages_count.to_s
        end

        def remove_existed_package
          xml.search("[pkgid='#{data[:pkgid]}']").each(&:remove)
        end
      end
    end
  end
end
