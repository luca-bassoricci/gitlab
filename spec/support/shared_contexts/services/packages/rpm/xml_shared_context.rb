# frozen_string_literal: true

RSpec.shared_context 'with rpm package data' do
  def xml_update_params
    Gitlab::Json.parse(fixture_file('packages/rpm/payload.json')).with_indifferent_access.tap do |data|
      data[:pkgid] = SecureRandom.uuid
    end
  end
end

RSpec.shared_context 'with primary xml file data' do
  let(:filename) { :primary }
  let(:empty_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <metadata xmlns="http://linux.duke.edu/metadata/common" xmlns:rpm="http://linux.duke.edu/metadata/rpm" packages="0"/>
    XML
  end
end

RSpec.shared_context 'with other xml file data' do
  let(:filename) { :other }
  let(:empty_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <otherdata xmlns="http://linux.duke.edu/metadata/other" packages="0"/>
    XML
  end
end
