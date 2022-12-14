import BasePolicy from 'ee/threat_monitoring/components/policy_drawer/base_policy.vue';
import CiliumNetworkPolicy from 'ee/threat_monitoring/components/policy_drawer/cilium_network_policy.vue';
import { toYaml } from 'ee/threat_monitoring/components/policy_editor/network_policy/lib';
import PolicyPreview from 'ee/threat_monitoring/components/policy_editor/policy_preview.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

describe('CiliumNetworkPolicy component', () => {
  let wrapper;
  const policy = {
    name: 'test-policy',
    description: 'test description',
    endpointLabels: '',
    rules: [],
  };
  const unsupportedYaml = 'unsupportedPrimaryKey: test';

  const findPolicyPreview = () => wrapper.findComponent(PolicyPreview);
  const findDescription = () => wrapper.findByTestId('description');

  const factory = ({ propsData } = {}) => {
    wrapper = shallowMountExtended(CiliumNetworkPolicy, {
      propsData: {
        ...propsData,
      },
      stubs: {
        BasePolicy,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('supported YAML', () => {
    beforeEach(() => {
      factory({ propsData: { value: toYaml(policy) } });
    });

    it('renders policy preview tabs', () => {
      expect(wrapper.find('div').element).toMatchSnapshot();
    });

    it('does render the policy description', () => {
      expect(findDescription().exists()).toBe(true);
      expect(findDescription().text()).toContain('test description');
    });

    it('does render the policy preview', () => {
      expect(findPolicyPreview().exists()).toBe(true);
      expect(findPolicyPreview().props()).toStrictEqual({
        initialTab: 0,
        policyDescription: 'Deny all traffic',
        policyYaml: toYaml(policy),
      });
    });
  });

  describe('unsupported YAML', () => {
    beforeEach(() => {
      factory({ propsData: { value: unsupportedYaml } });
    });

    it('renders policy preview tabs', () => {
      expect(wrapper.find('div').element).toMatchSnapshot();
    });

    it('does not render the policy description', () => {
      expect(findDescription().exists()).toBe(false);
    });

    it('does render the policy preview', () => {
      expect(findPolicyPreview().exists()).toBe(true);
      expect(findPolicyPreview().props()).toStrictEqual({
        initialTab: 1,
        policyDescription: null,
        policyYaml: unsupportedYaml,
      });
    });
  });
});
