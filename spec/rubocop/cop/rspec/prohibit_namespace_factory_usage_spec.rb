# frozen_string_literal: true

require 'fast_spec_helper'

require_relative '../../../../rubocop/cop/rspec/prohibit_namespace_factory_usage'

RSpec.describe RuboCop::Cop::RSpec::ProhibitNamespaceFactoryUsage do
  subject(:cop) { described_class.new }

  context 'offenses' do
    context 'standalone' do
      bad_samples = [
        'build(:namespace)',
        'build(:namespace, name: "a named namespace")',
        'create(:namespace)',
        'create(:namespace, name: "a named namespace")'
      ]

      bad_samples.each do |bad|
        context "bad: #{bad}" do
          it 'registers an offense' do
            expect_offense(<<~CODE, node: bad)
            %{node}
            ^{node} Do not use the `namespace` factory, [...]
            CODE
          end
        end
      end
    end

    context 'prefaced' do
      bad_samples = [
        'let(:my_namespace) { build(:namespace) }',
        'let(:my_namespace) { build(:namespace, name: "a named namespace") }',
        'let(:my_namespace) { create(:namespace) }',
        'let(:my_namespace) { create(:namespace, name: "a named namespace") }'
      ]

      bad_samples.each do |bad|
        context "bad: #{bad}" do
          it 'registers an offense' do
            expect_offense(<<~CODE, node: bad)
          %{node}
          #{' ' * 21}#{'^' * (bad.length - 23)} Do not use the `namespace` factory, [...]
            CODE
          end
        end
      end
    end
  end

  context 'things that are not offenses' do
    good_samples = [
        'build(:project_namespace)',
        'build(:project_namespace, name: "a named project namespace")',
        'let(:my_namespace) { build(:project_namespace, name: "a named project namespace") }',
        'create(:project_namespace)',
        'create(:project_namespace, name: "a named project namespace")',
        'let(:my_namespace) { create(:project_namespace, name: "a named project namespace") }',
        'build(:user_namespace)',
        'build(:user_namespace, name: "a named user namespace")',
        'let(:my_namespace) { build(:user_namespace, name: "a named user namespace") }',
        'create(:user_namespace)',
        'create(:user_namespace, name: "a named user namespace")',
        'let(:my_namespace) { create(:user_namespace, name: "a named user namespace") }',
        'build(:group)',
        'build(:group, name: "a named group")',
        'let(:my_namespace) { build(:group, name: "a named group") }',
        'create(:group)',
        'create(:group, name: "a named group")',
        'let(:my_namespace) { create(:group, name: "a named group") }',
        'create(:namespace_settings)',
        'let(:some_setting) { create(:namespace_settings) }',
        'create(:namespace_with_plan)',
        'let(:namespace_pl) { create(:namespace_with_plan) }'
    ]

    good_samples.each do |good|
      context "good: #{good}" do
        it 'does not register an offense' do
          expect_no_offenses(good)
        end
      end
    end
  end
end
