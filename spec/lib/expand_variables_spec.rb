# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ExpandVariables do
  shared_examples 'common variable expansion' do |expander|
    using RSpec::Parameterized::TableSyntax

    where do
      {
        "no expansion": {
          value: 'key',
          result: 'key',
          variables: []
        },
        "simple expansion": {
          value: 'key$variable',
          result: 'keyvalue',
          variables: [
            { key: 'variable', value: 'value' }
          ]
        },
        "simple with hash of variables": {
          value: 'key$variable',
          result: 'keyvalue',
          variables: {
            'variable' => 'value'
          }
        },
        "complex expansion": {
          value: 'key${variable}',
          result: 'keyvalue',
          variables: [
            { key: 'variable', value: 'value' }
          ]
        },
        "simple expansions": {
          value: 'key$variable$variable2',
          result: 'keyvalueresult',
          variables: [
            { key: 'variable', value: 'value' },
            { key: 'variable2', value: 'result' }
          ]
        },
        "complex expansions": {
          value: 'key${variable}${variable2}',
          result: 'keyvalueresult',
          variables: [
            { key: 'variable', value: 'value' },
            { key: 'variable2', value: 'result' }
          ]
        },
        "out-of-order expansion": {
          value: 'key$variable2$variable',
          result: 'keyresultvalue',
          variables: [
            { key: 'variable', value: 'value' },
            { key: 'variable2', value: 'result' }
          ]
        },
        "out-of-order complex expansion": {
          value: 'key${variable2}${variable}',
          result: 'keyresultvalue',
          variables: [
            { key: 'variable', value: 'value' },
            { key: 'variable2', value: 'result' }
          ]
        },
        "review-apps expansion": {
          value: 'review/$CI_COMMIT_REF_NAME',
          result: 'review/feature/add-review-apps',
          variables: [
            { key: 'CI_COMMIT_REF_NAME', value: 'feature/add-review-apps' }
          ]
        },
        "do not lazily access variables when no expansion": {
          value: 'key',
          result: 'key',
          variables: -> { raise NotImplementedError }
        },
        "lazily access variables": {
          value: 'key$variable',
          result: 'keyvalue',
          variables: -> { [{ key: 'variable', value: 'value' }] }
        },
        "simple expansion using Collection": {
          value: 'key$variable',
          result: 'keyvalue',
          variables: Gitlab::Ci::Variables::Collection.new([
            { key: 'variable', value: 'value' }
          ])
        }
      }
    end

    with_them do
      subject { expander.call(value, variables) }

      it { is_expected.to eq(result) }
    end
  end

  describe '#expand' do
    context 'table tests' do
      it_behaves_like 'common variable expansion', described_class.method(:expand)

      context 'with missing variables' do
        using RSpec::Parameterized::TableSyntax

        where do
          {
            "missing variable": {
              value: 'key$variable',
              result: 'key',
              variables: []
            },
            "complex expansions with missing variable": {
              value: 'key${variable}${variable2}',
              result: 'keyvalue',
              variables: [
                { key: 'variable', value: 'value' }
              ]
            },
            "complex expansions with missing variable for Windows": {
              value: 'key%variable%%variable2%',
              result: 'keyvalue',
              variables: [
                { key: 'variable', value: 'value' }
              ]
            },
            "complex expansions with escaped characters": {
              value: 'key_${variable4}_$${HOME}_%%HOME%%',
              result: 'key__${HOME}_%HOME%',
              variables: [
                { key: 'variable', value: 'value' }
              ]
            },
            "garbled reference is maintained verbatim - 1": {
              value: 'key${%',
              result: 'key${%'
            },
            "garbled reference is maintained verbatim - 2": {
              value: 'key$',
              result: 'key$'
            },
            "garbled reference is maintained verbatim - 3": {
              value: 'key%$%',
              result: 'key%$%'
            },
            "escaped characters are resolved correctly": {
              value: 'key-$TEST1-%%HOME%%-$${HOME}',
              variables: [
                { key: 'TEST1', value: 'test-3' }
              ],
              result: 'key-test-3-%HOME%-${HOME}'
            }
          }
        end

        with_them do
          subject { ExpandVariables.expand(value, variables) }

          it { is_expected.to eq(result) }
        end
      end
    end

    context 'lazily inits variables' do
      let(:variables) { -> { [{ key: 'variable', value: 'result' }] } }

      subject { described_class.expand(value, variables) }

      context 'when expanding variable' do
        let(:value) { 'key$variable$variable2' }

        it 'calls block at most once' do
          expect(variables).to receive(:call).once.and_call_original

          is_expected.to eq('keyresult')
        end
      end

      context 'when no expansion is needed' do
        let(:value) { 'key' }

        it 'does not call block' do
          expect(variables).not_to receive(:call)

          is_expected.to eq('key')
        end
      end
    end
  end

  describe '#expand_existing' do
    context 'table tests' do
      it_behaves_like 'common variable expansion', described_class.method(:expand_existing)

      context 'with missing variables' do
        using RSpec::Parameterized::TableSyntax

        where do
          {
            "missing variable": {
              value: 'key$variable',
              result: 'key$variable',
              variables: []
            },
            "complex expansions with missing variable": {
              value: 'key${variable}${variable2}',
              result: 'keyvalue${variable2}',
              variables: [
                { key: 'variable', value: 'value' }
              ]
            },
            "complex expansions with missing variable for Windows": {
              value: 'key%variable%%variable2%',
              result: 'keyvalue%variable2%',
              variables: [
                { key: 'variable', value: 'value' }
              ]
            },
            "complex expansions with escaped characters": {
              value: 'key_${variable}_$${HOME}_%%HOME%%',
              variables: [
                { key: 'variable', value: '$variable2' },
                { key: 'variable2', value: 'value' }
              ],
              result: 'key_$variable2_${HOME}_%HOME%'
            },
            "garbled reference is maintained verbatim - 1": {
              value: 'key${%',
              result: 'key${%'
            },
            "garbled reference is maintained verbatim - 2": {
              value: 'key${%$A',
              variables: [
                { key: 'A', value: 'value' }
              ],
              result: 'key${%value'
            },
            "garbled reference is maintained verbatim - 3": {
              value: 'key%$%',
              result: 'key%$%'
            },
            "complex escaped characters are resolved correctly": {
              value: 'key-$TEST2-${TEST3}-%TEST4%',
              variables: [
                { key: 'TEST1', value: 'test-3' },
                { key: 'TEST2', value: '$TEST1' },
                { key: 'TEST3', value: '$$TEST1' },
                { key: 'TEST4', value: '$$$TEST1' }
              ],
              result: 'key-$TEST1-$$TEST1-$$$TEST1'
            },
            "empty variable is resolved correctly": {
              value: '${TEST_EMPTY}',
              variables: [
                { key: 'TEST_EMPTY', value: '' }
              ],
              result: ''
            }
          }
        end

        with_them do
          subject { ExpandVariables.expand_existing(value, variables) }

          it { is_expected.to eq(result) }
        end
      end
    end

    context 'lazily inits variables' do
      let(:variables) { -> { [{ key: 'variable', value: 'result' }] } }

      subject { described_class.expand_existing(value, variables) }

      context 'when expanding variable' do
        let(:value) { 'key$variable$variable2' }

        it 'calls block at most once' do
          expect(variables).to receive(:call).once.and_call_original

          is_expected.to eq('keyresult$variable2')
        end
      end

      context 'when no expansion is needed' do
        let(:value) { 'key' }

        it 'does not call block' do
          expect(variables).not_to receive(:call)

          is_expected.to eq('key')
        end
      end
    end
  end

  describe '#possible_var_reference?' do
    context 'table tests' do
      using RSpec::Parameterized::TableSyntax

      where do
        {
          "empty value": {
            value: '',
            result: false
          },
          "normal value": {
            value: 'some value',
            result: false
          },
          "simple expansions": {
            value: 'key$variable',
            result: true
          },
          "complex expansions": {
            value: 'key${variable}${variable2}',
            result: true
          },
          "complex expansions for Windows": {
            value: 'key%variable%%variable2%',
            result: true
          }
        }
      end

      with_them do
        subject { ExpandVariables.possible_var_reference?(value) }

        it { is_expected.to eq(result) }
      end
    end
  end
end
