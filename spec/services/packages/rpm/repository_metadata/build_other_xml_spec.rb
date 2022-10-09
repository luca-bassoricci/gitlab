# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Packages::Rpm::RepositoryMetadata::BuildOtherXml do
  describe '#execute' do
    subject { described_class.execute(data) }

    context 'when updating existing xml' do
      include_context 'with rpm package data'

      let(:data) { xml_update_params }
      let(:changelog_xpath) { "//package/changelog" }

      it 'adds all changelog nodes' do
        result = subject

        expect(result.xpath(changelog_xpath).count).to eq(data[:changelogs].count)
      end

      it 'set required date attribute' do
        result = subject

        data[:changelogs].each do |changelog|
          expect(result.at("#{changelog_xpath}[@date=\"#{changelog[:changelogtime]}\"]")).not_to be_nil
        end
      end
    end
  end
end
