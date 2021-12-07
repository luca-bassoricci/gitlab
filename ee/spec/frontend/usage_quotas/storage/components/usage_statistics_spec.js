import { GlButton, GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import UsageStatistics from 'ee/usage_quotas/storage/components/usage_statistics.vue';
import UsageStatisticsCard from 'ee/usage_quotas/storage/components/usage_statistics_card.vue';
import { withRootStorageStatistics } from '../mock_data';

describe('UsageStatistics', () => {
  let wrapper;

  const createComponent = ({ props = {}, provide = {}, newRouteStoragePurchase = false } = {}) => {
    wrapper = shallowMount(UsageStatistics, {
      propsData: {
        rootStorageStatistics: {
          totalRepositorySize: withRootStorageStatistics.totalRepositorySize,
          actualRepositorySizeLimit: withRootStorageStatistics.actualRepositorySizeLimit,
          totalRepositorySizeExcess: withRootStorageStatistics.totalRepositorySizeExcess,
          additionalPurchasedStorageSize: withRootStorageStatistics.additionalPurchasedStorageSize,
        },
        ...props,
      },
      provide: {
        glFeatures: {
          newRouteStoragePurchase,
        },
        ...provide,
      },
      stubs: {
        UsageStatisticsCard,
        GlSprintf,
        GlLink,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const getStatisticsCards = () => wrapper.findAll(UsageStatisticsCard);
  const getStatisticsCard = (testId) => wrapper.find(`[data-testid="${testId}"]`);
  const findGlLinkInCard = (cardName) =>
    getStatisticsCard(cardName).find('[data-testid="statistics-card-footer"]').find(GlLink);
  const findPurchasedUsageButton = () =>
    getStatisticsCard('purchased-usage').findComponent(GlButton);

  describe('with purchaseStorageUrl passed and newRouteStoragePurchase flag enabled', () => {
    beforeEach(() => {
      createComponent({
        provide: {
          purchaseStorageUrl: 'some-fancy-url',
        },
        newRouteStoragePurchase: true,
      });
    });

    it('renders button in purchased usage card footer with correct link', () => {
      expect(findPurchasedUsageButton().attributes()).toMatchObject({
        href: 'some-fancy-url',
        target: '_self',
      });
    });
  });

  describe('with purchaseStorageUrl passed', () => {
    beforeEach(() => {
      createComponent({
        provide: {
          purchaseStorageUrl: 'some-fancy-url',
        },
      });
    });

    it('renders three statistics cards', () => {
      expect(getStatisticsCards()).toHaveLength(3);
    });

    it('renders URL in total usage card footer', () => {
      const url = findGlLinkInCard('total-usage');

      expect(url.attributes('href')).toBe('/help/user/usage_quotas');
    });

    it('renders URL in excess usage card footer', () => {
      const url = findGlLinkInCard('excess-usage');

      expect(url.attributes('href')).toBe('/help/user/usage_quotas#excess-storage-usage');
    });

    it('renders button in purchased usage card footer with correct link', () => {
      expect(findPurchasedUsageButton().attributes()).toMatchObject({
        href: 'some-fancy-url',
        target: '_blank',
      });
    });
  });

  describe('with no purchaseStorageUrl', () => {
    beforeEach(() => {
      createComponent({
        provide: {
          purchaseStorageUrl: null,
        },
      });
    });

    it('does not render purchased usage card if purchaseStorageUrl is not provided', () => {
      expect(getStatisticsCard('purchased-usage').exists()).toBe(false);
    });
  });
});
