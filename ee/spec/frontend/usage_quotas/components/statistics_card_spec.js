import { GlLink, GlButton, GlProgressBar } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import StatisticsCard from 'ee/usage_quotas/components/statistics_card.vue';

describe('StatisticsCard', () => {
  let wrapper;
  const defaultProps = {
    description: 'Dummy text for description',
    helpLink: 'http://test.gitlab.com/',
    purchaseButtonLink: 'http://gitlab.com/purchase',
    purchaseButtonText: 'Purchase more storage',
    percentage: 75,
  };
  const createComponent = (props = {}) => {
    wrapper = shallowMount(StatisticsCard, {
      propsData: props,
    });
  };

  describe('render', () => {
    it('does not render description if prop is not passed', () => {
      createComponent({ description: null });
      expect(wrapper.text()).not.toContain(defaultProps.description);
    });

    it('renders description if prop is passed', () => {
      createComponent(defaultProps);
      expect(wrapper.text()).toContain(defaultProps.description);
    });

    it('does not render help link if prop is not passed', () => {
      createComponent({ helpLink: null });
      expect(wrapper.findComponent(GlLink).exists()).toBe(false);
    });

    it('renders help link if prop is passed', () => {
      createComponent(defaultProps);
      expect(wrapper.findComponent(GlLink).exists()).toBe(true);
    });

    it('does not render purchase button if purchase link or purchase text is not passed', () => {
      createComponent({
        purchaseButtonLink: defaultProps.purchaseButtonLink,
        purchaseButtonText: null,
      });
      expect(wrapper.findComponent(GlButton).exists()).toBe(false);
      createComponent({
        purchaseButtonText: defaultProps.purchaseButtonText,
        purchaseButtonLink: null,
      });
      expect(wrapper.findComponent(GlButton).exists()).toBe(false);
    });

    it('renders purchase button if prop is passed', () => {
      createComponent(defaultProps);
      expect(wrapper.findComponent(GlButton).exists()).toBe(true);
    });

    it('does not render progress bar if prop is not passed', () => {
      createComponent({ percentage: null });
      expect(wrapper.findComponent(GlProgressBar).exists()).toBe(false);
    });

    it('renders progress bar if prop is passed', () => {
      createComponent(defaultProps);
      expect(wrapper.findComponent(GlProgressBar).exists()).toBe(true);
    });
  });
});
