import { GlSprintf, GlTabs } from '@gitlab/ui';
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import { merge } from 'lodash';
import onDemandScansCountsMock from 'test_fixtures/graphql/on_demand_scans/graphql/on_demand_scan_counts.query.graphql.json';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import OnDemandScans from 'ee/on_demand_scans/components/on_demand_scans.vue';
import { PIPELINE_TABS_KEYS } from 'ee/on_demand_scans/constants';
import ConfigurationPageLayout from 'ee/security_configuration/components/configuration_page_layout.vue';
import { createRouter } from 'ee/on_demand_scans/router';
import AllTab from 'ee/on_demand_scans/components/tabs/all.vue';
import EmptyState from 'ee/on_demand_scans/components/empty_state.vue';
import createMockApollo from 'helpers/mock_apollo_helper';
import onDemandScansCounts from 'ee/on_demand_scans/graphql/on_demand_scan_counts.query.graphql';
import flushPromises from 'helpers/flush_promises';

Vue.use(VueApollo);

describe('OnDemandScans', () => {
  let wrapper;
  let router;
  let requestHandler;

  // Props
  const newDastScanPath = '/on_demand_scans/new';
  const projectPath = '/namespace/project';
  const projectOnDemandScanCountsEtag = `/api/graphql:on_demand_scan/counts/${projectPath}`;
  const nonEmptyInitialPipelineCounts = {
    all: 12,
    running: 3,
    finished: 9,
    scheduled: 5,
  };
  const emptyInitialPipelineCounts = Object.fromEntries(PIPELINE_TABS_KEYS.map((key) => [key, 0]));

  // Finders
  const findNewScanLink = () => wrapper.findByTestId('new-scan-link');
  const findHelpPageLink = () => wrapper.findByTestId('help-page-link');
  const findTabs = () => wrapper.findComponent(GlTabs);
  const findAllTab = () => wrapper.findComponent(AllTab);
  const findEmptyState = () => wrapper.findComponent(EmptyState);

  // Helpers
  const createMockApolloProvider = () => {
    return createMockApollo([[onDemandScansCounts, requestHandler]]);
  };

  const createComponent = (options = {}) => {
    wrapper = shallowMountExtended(
      OnDemandScans,
      merge(
        {
          apolloProvider: createMockApolloProvider(),
          router,
          provide: {
            newDastScanPath,
            projectPath,
            projectOnDemandScanCountsEtag,
          },
          stubs: {
            ConfigurationPageLayout,
            GlSprintf,
            GlTabs,
          },
        },
        {
          propsData: {
            initialOnDemandScanCounts: nonEmptyInitialPipelineCounts,
          },
        },
        options,
      ),
    );
  };

  beforeEach(() => {
    requestHandler = jest.fn().mockResolvedValue(onDemandScansCountsMock);
    router = createRouter();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders an empty state when there is no data', () => {
    createComponent({
      propsData: {
        initialOnDemandScanCounts: emptyInitialPipelineCounts,
      },
    });

    expect(findEmptyState().exists()).toBe(true);
  });

  it('updates on-demand scans counts and shows the tabs once there is some data', async () => {
    createComponent({
      propsData: {
        initialOnDemandScanCounts: emptyInitialPipelineCounts,
      },
    });

    expect(findTabs().exists()).toBe(false);
    expect(findEmptyState().exists()).toBe(true);
    expect(requestHandler).toHaveBeenCalled();

    await flushPromises();

    expect(findTabs().exists()).toBe(true);
    expect(findEmptyState().exists()).toBe(false);
  });

  describe('when there is data', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders a link to the docs', () => {
      const link = findHelpPageLink();

      expect(link.exists()).toBe(true);
      expect(link.attributes('href')).toBe(
        '/help/user/application_security/dast/index#on-demand-scans',
      );
    });

    it('renders a link to create a new scan', () => {
      const link = findNewScanLink();

      expect(link.exists()).toBe(true);
      expect(link.attributes('href')).toBe(newDastScanPath);
    });

    it('renders the tabs', () => {
      expect(findAllTab().exists()).toBe(true);
    });

    it('sets the initial route to /all', () => {
      expect(findTabs().props('value')).toBe(0);
      expect(router.currentRoute.path).toBe('/all');
    });
  });
});
