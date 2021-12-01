# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Config::Entry::Variables do
  let(:metadata) { {} }

  subject(:variables) { described_class.new(config, **metadata) }

  before do
    variables.compose!
  end

  shared_examples 'valid config' do
    describe '#value' do
      it 'returns hash with key value strings' do
        expect(subject.value).to eq(result)
      end
    end

    describe '#errors' do
      it 'does not append errors' do
        expect(subject.errors).to be_empty
      end
    end

    describe '#valid?' do
      it 'is valid' do
        expect(subject).to be_valid
      end
    end
  end

  shared_examples 'invalid config' do |error_message|
    describe '#valid?' do
      it 'is not valid' do
        expect(subject).not_to be_valid
      end
    end

    describe '#errors' do
      it 'saves errors' do
        expect(subject.errors)
          .to include(error_message)
      end
    end
  end

  context 'when entry config value has key-value pairs' do
    let(:config) do
      { 'VARIABLE_1' => 'value 1', 'VARIABLE_2' => 'value 2' }
    end

    let(:result) do
      [{ key: 'VARIABLE_1', value: 'value 1' }, { key: 'VARIABLE_2', value: 'value 2' }]
    end

    it_behaves_like 'valid config'
  end

  context 'with numeric keys and values in the config' do
    let(:config) { { 10 => 20 } }
    let(:result) do
      [{ key: '10', value: '20' }]
    end

    it_behaves_like 'valid config'
  end

  context 'when entry config value has key-value pair and hash' do
    let(:config) do
      { 'VARIABLE_1' => { value: 'value 1', description: 'variable 1' },
        'VARIABLE_2' => 'value 2' }
    end

    let(:result) do
      [{ key: 'VARIABLE_1', value: 'value 1', description: 'variable 1' }, { key: 'VARIABLE_2', value: 'value 2' }]
    end

    it_behaves_like 'valid config'
  end

  context 'when entry value is an array' do
    let(:config) { [:VAR, 'test'] }

    it_behaves_like 'invalid config', 'variables config should be a hash'
  end
end
