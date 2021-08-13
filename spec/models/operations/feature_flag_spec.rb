# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Operations::FeatureFlag do
  include FeatureFlagHelpers

  subject { create(:operations_feature_flag) }

  it_behaves_like 'includes Limitable concern' do
    subject { build(:operations_feature_flag, project: create(:project)) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:strategies) }
  end

  describe '.reference_pattern' do
    subject { described_class.reference_pattern }

    it { is_expected.to match('[feature_flag:123]') }
    it { is_expected.to match('[feature_flag:gitlab-org/gitlab/123]') }
  end

  describe '.link_reference_pattern' do
    subject { described_class.link_reference_pattern }

    it { is_expected.to match("#{Gitlab.config.gitlab.url}/gitlab-org/gitlab/-/feature_flags/123/edit") }
    it { is_expected.not_to match("#{Gitlab.config.gitlab.url}/gitlab-org/gitlab/issues/123/edit") }
    it { is_expected.not_to match("gitlab-org/gitlab/-/feature_flags/123/edit") }
  end

  describe '#to_reference' do
    let(:namespace) { build(:namespace, path: 'sample-namespace') }
    let(:project) { build(:project, name: 'sample-project', namespace: namespace) }
    let(:feature_flag) { build(:operations_feature_flag, iid: 1, project: project) }

    it 'returns feature flag id' do
      expect(feature_flag.to_reference).to eq '[feature_flag:1]'
    end

    it 'returns complete path to the feature flag with full: true' do
      expect(feature_flag.to_reference(full: true)).to eq '[feature_flag:sample-namespace/sample-project/1]'
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:project_id) }

    it 'is valid if associated with Operations::FeatureFlags::Strategy models' do
      project = create(:project)
      feature_flag = described_class.create!({ name: 'test', project: project,
                                              strategies_attributes: [{ name: 'default', parameters: {} }] })

      expect(feature_flag).to be_valid
    end

    it_behaves_like 'AtomicInternalId', validate_presence: true do
      let(:internal_id_attribute) { :iid }
      let(:instance) { build(:operations_feature_flag) }
      let(:scope) { :project }
      let(:scope_attrs) { { project: instance.project } }
      let(:usage) { :operations_feature_flags }
    end
  end

  describe '.enabled' do
    subject { described_class.enabled }

    context 'when the feature flag is active' do
      let!(:feature_flag) { create(:operations_feature_flag, active: true) }

      it 'returns the flag' do
        is_expected.to eq([feature_flag])
      end
    end

    context 'when the feature flag is inactive' do
      let!(:feature_flag) { create(:operations_feature_flag, active: false) }

      it 'does not return the flag' do
        is_expected.to be_empty
      end
    end
  end

  describe '.disabled' do
    subject { described_class.disabled }

    context 'when the feature flag is active' do
      let!(:feature_flag) { create(:operations_feature_flag, active: true) }

      it 'does not return the flag' do
        is_expected.to be_empty
      end
    end

    context 'when the feature flag is inactive' do
      let!(:feature_flag) { create(:operations_feature_flag, active: false) }

      it 'returns the flag' do
        is_expected.to eq([feature_flag])
      end
    end
  end

  describe '.for_unleash_client' do
    let_it_be(:project) { create(:project) }

    let!(:feature_flag) do
      create(:operations_feature_flag, project: project,
             name: 'feature1', active: true)
    end

    let!(:strategy) do
      create(:operations_strategy, feature_flag: feature_flag,
             name: 'default', parameters: {})
    end

    it 'matches wild cards in the scope' do
      create(:operations_scope, strategy: strategy, environment_scope: 'review/*')

      flags = described_class.for_unleash_client(project, 'review/feature-branch')

      expect(flags).to eq([feature_flag])
    end

    it 'matches wild cards case sensitively' do
      create(:operations_scope, strategy: strategy, environment_scope: 'Staging/*')

      flags = described_class.for_unleash_client(project, 'staging/feature')

      expect(flags).to eq([])
    end

    it 'returns feature flags ordered by id' do
      create(:operations_scope, strategy: strategy, environment_scope: 'production')
      feature_flag_b = create(:operations_feature_flag, project: project,
                              name: 'feature2', active: true)
      strategy_b = create(:operations_strategy, feature_flag: feature_flag_b,
                          name: 'default', parameters: {})
      create(:operations_scope, strategy: strategy_b, environment_scope: '*')

      flags = described_class.for_unleash_client(project, 'production')

      expect(flags.map(&:id)).to eq([feature_flag.id, feature_flag_b.id])
    end
  end

  describe '#hook_attrs' do
    it 'includes expected attributes' do
      hook_attrs = {
        id: subject.id,
        name: subject.name,
        description: subject.description,
        active: subject.active
      }
      expect(subject.hook_attrs).to eq(hook_attrs)
    end
  end

  describe "#execute_hooks" do
    let_it_be(:user) { create(:user) }
    let_it_be(:project) { create(:project) }
    let_it_be(:feature_flag) { create(:operations_feature_flag, project: project) }

    it 'does not execute the hook when feature_flag event is disabled' do
      create(:project_hook, project: project, feature_flag_events: false)
      expect(WebHookWorker).not_to receive(:perform_async)

      feature_flag.execute_hooks(user)
      feature_flag.touch
    end

    it 'executes hook when feature_flag event is enabled' do
      hook = create(:project_hook, project: project, feature_flag_events: true)
      expect(WebHookWorker).to receive(:perform_async).with(hook.id, an_instance_of(Hash), 'feature_flag_hooks')

      feature_flag.execute_hooks(user)
      feature_flag.touch
    end
  end
end
