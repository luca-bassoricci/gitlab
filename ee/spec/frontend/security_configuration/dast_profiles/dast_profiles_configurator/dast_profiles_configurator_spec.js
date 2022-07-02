import { merge } from 'lodash';
import { GlLink } from '@gitlab/ui';
import VueApollo from 'vue-apollo';
import { nextTick } from 'vue';
import { createLocalVue, mount, shallowMount } from '@vue/test-utils';
import siteProfilesFixtures from 'test_fixtures/graphql/security_configuration/dast_profiles/graphql/dast_site_profiles.query.graphql.basic.json';
import scannerProfilesFixtures from 'test_fixtures/graphql/security_configuration/dast_profiles/graphql/dast_scanner_profiles.query.graphql.basic.json';
import { s__ } from '~/locale';
import DastProfilesConfigurator from 'ee/security_configuration/dast_profiles/dast_profiles_configurator/dast_profiles_configurator.vue';
import DastProfilesConfiguratorModal from 'ee/security_configuration/dast_profiles/dast_profiles_configurator/dast_profiles_configurator_modal.vue';
import ScannerProfileSelector from 'ee/security_configuration/dast_profiles/dast_profile_selector/scanner_profile_selector.vue';
import SiteProfileSelector from 'ee/security_configuration/dast_profiles/dast_profile_selector/site_profile_selector.vue';
import ScannerProfileSummary from 'ee/security_configuration/dast_profiles/dast_profile_selector/scanner_profile_summary.vue';
import SiteProfileSummary from 'ee/security_configuration/dast_profiles/dast_profile_selector/site_profile_summary.vue';
import DastProfilesSidebar from 'ee/security_configuration/dast_profiles/dast_profiles_sidebar/dast_profiles_sidebar.vue';
import DastProfilesSidebarList from 'ee/security_configuration/dast_profiles/dast_profiles_sidebar/dast_profiles_sidebar_list.vue';
import DastProfilesSidebarForm from 'ee/security_configuration/dast_profiles/dast_profiles_sidebar/dast_profiles_sidebar_form.vue';
import SectionLayout from '~/vue_shared/security_configuration/components/section_layout.vue';
import SectionLoader from '~/vue_shared/security_configuration/components/section_loader.vue';
import dastScannerProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_scanner_profiles.query.graphql';
import dastSiteProfilesQuery from 'ee/security_configuration/dast_profiles/graphql/dast_site_profiles.query.graphql';
import createApolloProvider from 'helpers/mock_apollo_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { SCANNER_TYPE, SIDEBAR_VIEW_MODE, REFERRAL_EVENT } from 'ee/on_demand_scans/constants';
import {
  siteProfiles,
  scannerProfiles,
} from 'ee_jest/security_configuration/dast_profiles/mocks/mock_data';

describe('DastProfilesConfigurator', () => {
  let localVue;
  let wrapper;
  let requestHandlers;
  const projectPath = 'projectPath';

  const createMockApolloProvider = (handlers) => {
    localVue.use(VueApollo);

    requestHandlers = {
      dastScannerProfiles: jest.fn().mockResolvedValue(scannerProfilesFixtures),
      dastSiteProfiles: jest.fn().mockResolvedValue(siteProfilesFixtures),
      ...handlers,
    };

    return createApolloProvider([
      [dastScannerProfilesQuery, requestHandlers.dastScannerProfiles],
      [dastSiteProfilesQuery, requestHandlers.dastSiteProfiles],
    ]);
  };

  const findModal = () => wrapper.findByTestId('discard-changes-modal');
  const findNewScanButton = () => wrapper.findByTestId('new-profile-button');
  const findOpenDrawerButton = () => wrapper.findByTestId('select-profile-action-btn');
  const findCancelButton = () => wrapper.findByTestId('dast-profile-form-cancel-button');
  const findSectionLayout = () => wrapper.findComponent(SectionLayout);
  const findSectionLoader = () => wrapper.findComponent(SectionLoader);
  const findScannerProfilesSelector = () => wrapper.findComponent(ScannerProfileSelector);
  const findSiteProfilesSelector = () => wrapper.findComponent(SiteProfileSelector);
  const findAllScannerProfileSummary = () => wrapper.findAllComponents(ScannerProfileSummary);
  const findAllSiteProfileSummary = () => wrapper.findAllComponents(SiteProfileSummary);
  const findDastProfileSidebar = () => wrapper.findComponent(DastProfilesSidebar);
  const findDastProfilesSidebarList = () => wrapper.findComponent(DastProfilesSidebarList);
  const findDastProfilesSidebarForm = () => wrapper.findComponent(DastProfilesSidebarForm);
  const findDastProfilesSidebarModal = () => wrapper.findComponent(DastProfilesConfiguratorModal);

  const createComponentFactory = (mountFn = shallowMount) => (options = {}, withHandlers) => {
    localVue = createLocalVue();
    let defaultMocks = {
      $apollo: {
        mutate: jest.fn(),
        queries: {
          scannerProfiles: jest.fn(),
          siteProfiles: jest.fn(),
        },
      },
    };
    let apolloProvider;
    if (withHandlers) {
      apolloProvider = createMockApolloProvider(withHandlers);
      defaultMocks = {};
    }
    wrapper = extendedWrapper(
      mountFn(
        DastProfilesConfigurator,
        merge(
          {},
          {
            propsData: {
              ...options,
            },
            mocks: defaultMocks,
            stubs: {
              SectionLayout,
              ScannerProfileSelector,
              SiteProfileSelector,
              DastProfilesConfiguratorModal,
              GlModal: true,
            },
            provide: {
              projectPath,
            },
          },
          { ...options, localVue, apolloProvider },

          {
            data() {
              return {
                scannerProfiles,
                siteProfiles,
                ...options.data,
              };
            },
          },
        ),
      ),
    );
    return wrapper;
  };
  const createComponent = createComponentFactory(mount);
  const createShallowComponent = createComponentFactory();

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when default state', () => {
    it('renders properly', () => {
      const sectionHeader = s__('OnDemandScans|DAST configuration');
      createComponent({ configurationHeader: sectionHeader });

      expect(findSectionLayout().find('h2').text()).toContain(sectionHeader);
      expect(findScannerProfilesSelector().exists()).toBe(true);
      expect(findSiteProfilesSelector().exists()).toBe(true);
    });

    it('renders a link to the docs', () => {
      createComponent();
      const link = findSectionLayout().find(GlLink);

      expect(link.exists()).toBe(true);
      expect(link.attributes('href')).toBe(
        '/help/user/application_security/dast/index#on-demand-scans',
      );
    });

    it.each`
      scannerProfilesLoading | siteProfilesLoading | isLoading
      ${true}                | ${true}             | ${true}
      ${false}               | ${true}             | ${true}
      ${true}                | ${false}            | ${true}
      ${false}               | ${false}            | ${false}
    `(
      'sets loading state to $isLoading if scanner profiles loading is $scannerProfilesLoading and site profiles loading is $siteProfilesLoading',
      ({ scannerProfilesLoading, siteProfilesLoading, isLoading }) => {
        createShallowComponent({
          mocks: {
            $apollo: {
              queries: {
                scannerProfiles: { loading: scannerProfilesLoading },
                siteProfiles: { loading: siteProfilesLoading },
              },
            },
          },
        });

        expect(findSectionLoader().exists()).toBe(isLoading);
      },
    );
  });

  describe('profile drawer', () => {
    beforeEach(() => {
      createComponent();
    });

    it('should open drawer with scanner profiles', async () => {
      findScannerProfilesSelector().vm.$emit('open-drawer');

      await nextTick();

      expect(findDastProfileSidebar().exists()).toBe(true);
      expect(findAllScannerProfileSummary()).toHaveLength(scannerProfiles.length);
    });

    it('should open drawer with site profiles', async () => {
      findSiteProfilesSelector().vm.$emit('open-drawer');

      await nextTick();

      expect(findDastProfileSidebar().exists()).toBe(true);
      expect(findAllSiteProfileSummary()).toHaveLength(siteProfiles.length);
    });
  });

  describe('saved profiles', () => {
    const savedProfiles = {
      dastScannerProfile: { id: scannerProfiles[0].id },
      dastSiteProfile: { id: siteProfiles[0].id },
    };

    it('should have profiles selected if saved profiles exist', () => {
      createComponent({ savedProfiles });

      expect(findScannerProfilesSelector().find('h3').text()).toContain(
        scannerProfiles[0].profileName,
      );
      expect(findSiteProfilesSelector().find('h3').text()).toContain(siteProfiles[0].profileName);
    });
  });

  describe('switching between modes', () => {
    beforeEach(() => {
      createComponent();
    });

    const openDrawer = async () => {
      findOpenDrawerButton().vm.$emit('click');
      await nextTick();
    };

    const expectEditingMode = async () => {
      findNewScanButton().vm.$emit('click');
      await nextTick();
      expect(findDastProfilesSidebarForm().exists()).toBe(true);
    };

    it('should have reading mode by default', async () => {
      await openDrawer();

      expect(findDastProfilesSidebarList().exists()).toBe(true);
    });

    it('should have editing mode by default', async () => {
      await openDrawer();
      await expectEditingMode();
    });

    it('should return from editing mode to reading mode', async () => {
      await openDrawer();
      await expectEditingMode();

      findCancelButton().vm.$emit('click');
      await nextTick();

      expect(findDastProfilesSidebarList().exists()).toBe(true);
    });
  });

  describe('warning modal', () => {
    beforeEach(async () => {
      createComponent();
      findOpenDrawerButton().vm.$emit('click');
      await nextTick();
    });

    it.each`
      event              | expectedResult
      ${'reopen-drawer'} | ${'true'}
      ${'close-drawer'}  | ${'true'}
    `('should show warning modal when changes are unsaved', async ({ event, expectedResult }) => {
      findDastProfileSidebar().vm.$emit('touched', true);
      await nextTick();

      findDastProfileSidebar().vm.$emit(event, {
        mode: SIDEBAR_VIEW_MODE.READING_MODE,
        profileType: SCANNER_TYPE,
      });
      await nextTick();

      expect(findModal().attributes('visible')).toBe(expectedResult);
    });

    it('should emit events up if there are no unsaved changes', async () => {
      findDastProfileSidebar().vm.$emit('touched', false);
      await nextTick();

      findDastProfileSidebar().vm.$emit('reopen-drawer', {
        mode: SIDEBAR_VIEW_MODE.READING_MODE,
        profileType: SCANNER_TYPE,
      });
      await nextTick();

      expect(findModal().attributes('visible')).toBe(undefined);
      expect(findDastProfilesSidebarModal().emitted()).toEqual({
        [REFERRAL_EVENT.OPEN]: [
          [{ mode: SIDEBAR_VIEW_MODE.READING_MODE, profileType: SCANNER_TYPE }],
          [{ mode: SIDEBAR_VIEW_MODE.READING_MODE, profileType: SCANNER_TYPE }],
        ],
      });
    });
  });
});
