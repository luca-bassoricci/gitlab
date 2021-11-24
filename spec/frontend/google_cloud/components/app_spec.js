import { shallowMount } from '@vue/test-utils';
import { GlTab, GlTabs } from '@gitlab/ui';
import App from '~/google_cloud/components/app.vue';
import IncubationBanner from '~/google_cloud/components/incubation_banner.vue';
import ServiceAccountsList from '~/google_cloud/components/service_accounts_list.vue';
import ServiceAccountsForm from '~/google_cloud/components/service_accounts_form.vue';
import GcpError from '~/google_cloud/components/errors/gcp_error.vue';
import NoGcpProjects from '~/google_cloud/components/errors/no_gcp_projects.vue';

describe('google_cloud App component', () => {
  let wrapper;

  const findIncubationBanner = () => wrapper.findComponent(IncubationBanner);
  const findGcpError = () => wrapper.findComponent(GcpError);
  const findNoGcpProjects = () => wrapper.findComponent(NoGcpProjects);
  const findServiceAccountsForm = () => wrapper.findComponent(ServiceAccountsForm);
  const findTabs = () => wrapper.findComponent(GlTabs);
  const findTabItems = () => findTabs().findAllComponents(GlTab);
  const findConfigurationTab = () => findTabItems().at(0);
  const findDeploymentTab = () => findTabItems().at(1);
  const findServicesTab = () => findTabItems().at(2);
  const findServiceAccountsList = () => findConfigurationTab().findComponent(ServiceAccountsList);

  describe('for gcp_error screen', () => {
    beforeEach(() => {
      const propsData = {
        screen: 'gcp_error',
        error: 'mock_gcp_client_error',
      };
      wrapper = shallowMount(App, { propsData });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('renders the gcp_error screen', () => {
      expect(findGcpError().exists()).toBe(true);
    });
  });

  describe('for no_gcp_projects screen', () => {
    beforeEach(() => {
      const propsData = {
        screen: 'no_gcp_projects',
      };
      wrapper = shallowMount(App, { propsData });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('renders the no_gcp_projects screen', () => {
      expect(findNoGcpProjects().exists()).toBe(true);
    });
  });

  describe('for service_accounts_form screen', () => {
    beforeEach(() => {
      const propsData = {
        screen: 'service_accounts_form',
        gcpProjects: [1, 2, 3],
        environments: [4, 5, 6],
        cancelPath: '',
      };
      wrapper = shallowMount(App, { propsData });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('renders the service_accounts_form screen', () => {
      expect(findServiceAccountsForm().exists()).toBe(true);
    });
  });

  describe('for home screen', () => {
    beforeEach(() => {
      const propsData = {
        screen: 'home',
        serviceAccounts: [{}, {}],
        createServiceAccountUrl: '#url-create-service-account',
        emptyIllustrationUrl: '#url-empty-illustration',
      };
      wrapper = shallowMount(App, { propsData });
    });

    afterEach(() => {
      wrapper.destroy();
    });

    it('should contain incubation banner', () => {
      expect(findIncubationBanner().exists()).toBe(true);
    });

    describe('google_cloud App tabs', () => {
      it('should contain tabs', () => {
        expect(findTabs().exists()).toBe(true);
      });

      it('should contain three tab items', () => {
        expect(findTabItems().length).toBe(3);
      });

      describe('configuration tab', () => {
        it('should exist', () => {
          expect(findConfigurationTab().exists()).toBe(true);
        });

        it('should contain service accounts component', () => {
          expect(findServiceAccountsList().exists()).toBe(true);
        });
      });

      describe('deployments tab', () => {
        it('should exist', () => {
          expect(findDeploymentTab().exists()).toBe(true);
        });
      });

      describe('services tab', () => {
        it('should exist', () => {
          expect(findServicesTab().exists()).toBe(true);
        });
      });
    });
  });
});
