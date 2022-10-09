# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Packages::Rpm::RepositoryMetadata::BuildPrimaryXml do
  describe '#execute' do
    subject { described_class.execute(data) }

    context 'when updating existing xml' do
      include_context 'with rpm package data'

      let(:data) { xml_update_params }
      let(:required_text_only_attributes) { %i[description summary arch name] }

      it 'adds node with required_text_only_attributes' do
        result = subject

        required_text_only_attributes.each do |attribute|
          expect(
            result.at("//package/#{attribute}").text
          ).to eq(data[attribute])
        end
      end
    end
  end
end
