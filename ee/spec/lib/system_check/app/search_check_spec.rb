# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SystemCheck::App::SearchCheck do
  before do
    # `info` is memoized, so we must clear it out to avoid test pollution
    described_class.instance_variable_set(:@info, nil)
  end

  describe '#info' do
    it 'returns search client info' do
      allow(Gitlab::Elastic::Helper).to receive_message_chain(:default, :client, :info)
        .and_return('the-info')

      expect(described_class.info).to eq('the-info')
    end
  end

  describe '#distribution' do
    context 'opensearch' do
      it 'returns `opensearch`' do
        allow(described_class).to receive(:info).and_return({
          'version' => { 'distribution' => 'opensearch' }
        })
        expect(described_class.distribution).to eq('opensearch')
      end
    end

    context 'elasticsearch' do
      it 'returns elasticsearch' do
        allow(described_class).to receive(:info).and_return({}) # no distribution key
        expect(described_class.distribution).to eq('elasticsearch')
      end
    end
  end

  describe '#current_version' do
    it 'returns version from self.info' do
      allow(described_class).to receive(:info).and_return({
        'version' => { 'number' => '867.53.09' }
      })

      expect(described_class.current_version).to eq(Gitlab::VersionInfo.parse('867.53.09'))
    end
  end

  describe '#skip?' do
    subject { described_class.new.skip? }

    context 'with elasticsearch disabled' do
      before do
        allow(Gitlab::CurrentSettings.current_application_settings)
          .to receive(:elasticsearch_indexing?).and_return(false)
      end

      it { is_expected.to be_truthy }
    end

    context 'with elasticsearch enabled' do
      before do
        allow(Gitlab::CurrentSettings.current_application_settings)
          .to receive(:elasticsearch_indexing?).and_return(true)
      end

      it { is_expected.not_to be_truthy }
    end
  end

  describe '.check?' do
    using RSpec::Parameterized::TableSyntax

    subject { described_class.new.check? }

    where(:distribution, :version, :result) do
      'elasticsearch' | '6.4.2' | false
      'elasticsearch' | '7.1.0' | true
      'elasticsearch' | '7.5.1' | true
      'elasticsearch' | '8.5.1' | true
      'elasticsearch' | '9.0.1' | false
      'opensearch' | '0.1.0' | false
      'opensearch' | '1.0.0' | true
      'opensearch' | '1.2.4' | true
      'opensearch' | '5.6.0' | false
      'opensearch' | '6.0.0' | false
    end

    with_them do
      before do
        info = { 'version' => { 'number' => version } }

        # Only opensearch includes the distribution key
        info['version']['distribution'] = 'opensearch' if distribution == 'opensearch'

        allow(described_class).to receive(:info).and_return(info)
      end

      it { is_expected.to eq(result) }
    end
  end

  describe '.show_error' do
    it 'returns the elasticsearch.md page' do
      checker = described_class.new
      error_msg = 'dummy error message'

      expect(checker).to receive(:for_more_information).with('doc/integration/elasticsearch.md').and_return(error_msg)
      expect(checker.show_error).to eq(error_msg)
    end
  end
end
