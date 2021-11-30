# frozen_string_literal: true

require 'fast_spec_helper'
require 'support/helpers/stubbed_feature'
require 'support/helpers/stub_feature_flags'

RSpec.describe Gitlab::Ci::Config::Normalizer::MatrixStrategy do
  include StubFeatureFlags

  describe '.applies_to?' do
    subject { described_class.applies_to?(config) }

    context 'with hash that has :matrix key' do
      let(:config) { { matrix: [] } }

      it { is_expected.to be_truthy }
    end

    context 'with hash that does not have :matrix key' do
      let(:config) { { number: [] } }

      it { is_expected.to be_falsey }
    end

    context 'with a number' do
      let(:config) { 5 }

      it { is_expected.to be_falsey }
    end
  end

  describe '.build_from' do
    subject { described_class.build_from('test', config) }

    let(:config) do
      {
        matrix: [
          [{ key: 'PROVIDER', value: %w[aws] }, { key: 'STACK', value: %w[app1 app2] }],
          [{ key: 'PROVIDER', value: %w[ovh gcp] }, { key: 'STACK', value: %w[app] }]
        ]
      }
    end

    it { expect(subject.size).to eq(4) }

    it 'has attributes' do
      expect(subject.map(&:attributes)).to match_array(
        [
          {
            name: 'test: [aws, app1]',
            instance: 1,
            parallel: { total: 4 },
            job_variables: [
              { key: 'PROVIDER', value: 'aws' },
              { key: 'STACK', value: 'app1' }
            ]
          },
          {
            name: 'test: [aws, app2]',
            instance: 2,
            parallel: { total: 4 },
            job_variables: [
              { key: 'PROVIDER', value: 'aws' },
              { key: 'STACK', value: 'app2' }
            ]
          },
          {
            name: 'test: [ovh, app]',
            instance: 3,
            parallel: { total: 4 },
            job_variables: [
              { key: 'PROVIDER', value: 'ovh' },
              { key: 'STACK', value: 'app' }
            ]
          },
          {
            name: 'test: [gcp, app]',
            instance: 4,
            parallel: { total: 4 },
            job_variables: [
              { key: 'PROVIDER', value: 'gcp' },
              { key: 'STACK', value: 'app' }
            ]
          }
        ]
      )
    end

    it 'has parallelized name' do
      expect(subject.map(&:name)).to match_array(
        ['test: [aws, app1]', 'test: [aws, app2]', 'test: [gcp, app]', 'test: [ovh, app]']
      )
    end
  end
end
