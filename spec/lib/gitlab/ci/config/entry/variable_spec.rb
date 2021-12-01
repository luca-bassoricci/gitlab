# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::Ci::Config::Entry::Variable do
  subject(:variable) { described_class.new(config) }

  before do
    variable.key = 'hello'
  end

  context 'when config is a hash' do
    context 'when config is valid' do
      let(:config) { { value: 'world', description: 'this is the hello variable' } }

      it { is_expected.to be_valid }

      it 'returns variable configuration' do
        expect(variable.value).to eq({ key: 'hello', value: 'world', description: 'this is the hello variable' })
      end
    end

    context 'when config has unsupported keys' do
      let(:config) { { hello: 'world' } }

      it { is_expected.not_to be_valid }
    end
  end

  context 'when config is not a hash' do
    let(:config) { 10 }

    it { is_expected.to be_valid }

    it 'returns variable configuration' do
      expect(variable.value).to eq({ key: 'hello', value: '10' })
    end
  end
end
