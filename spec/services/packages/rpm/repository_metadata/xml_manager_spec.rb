# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Packages::Rpm::RepositoryMetadata::XmlManager do
  describe '#execute' do
    context 'when building empty xml' do
      subject { described_class.new(filename: filename).execute }

      shared_examples 'generating empty xml' do
        it 'generate expected xml' do
          expect(subject).to eq(empty_xml)
        end
      end

      context "for 'primary' xml file" do
        include_context 'with primary xml file data'

        it_behaves_like 'generating empty xml'
      end

      context "for 'other' xml file" do
        include_context 'with other xml file data'

        it_behaves_like 'generating empty xml'
      end
    end

    context 'when updating xml file' do
      subject { described_class.new(filename: filename, xml: xml, data: data).execute }

      include_context 'with rpm package data'

      let(:xml) { empty_xml }
      let(:data) { xml_update_params }
      let(:builder_class) { described_class::BUILDERS[filename] }

      shared_examples 'updating rpm xml file' do
        context 'when updating existing xml' do
          shared_examples 'changing root tag attribute' do
            it "increment previous 'packages' value by 1" do
              previous_value = Nokogiri::XML(xml).at(builder_class::ROOT_TAG).attributes["packages"].value.to_i
              new_value = Nokogiri::XML(subject).at(builder_class::ROOT_TAG).attributes["packages"].value.to_i

              expect(previous_value + 1).to eq(new_value)
            end
          end

          it 'generate valid xml add expected xml node to existing xml' do
            # Have one root attribute
            result = Nokogiri::XML::Document.parse(subject).remove_namespaces!
            expect(result.children.count).to eq(1)

            # Root node has 1 child with generated node
            expect(result.xpath("//#{builder_class::ROOT_TAG}/package").count).to eq(1)
          end

          context 'when empty xml' do
            it_behaves_like 'changing root tag attribute'
          end

          context 'when xml has children' do
            let(:xml) { described_class.new(filename: filename, xml: empty_xml, data: xml_update_params).execute }

            it 'has children nodes' do
              result = Nokogiri::XML::Document.parse(xml).remove_namespaces!
              expect(result.children.count).to be > 0
            end

            it_behaves_like 'changing root tag attribute'
          end
        end
      end

      context "for 'primary' xml file" do
        include_context 'with primary xml file data'

        it_behaves_like 'updating rpm xml file'
      end

      context "for 'other' xml file" do
        include_context 'with other xml file data'

        it_behaves_like 'updating rpm xml file'
      end
    end
  end
end
