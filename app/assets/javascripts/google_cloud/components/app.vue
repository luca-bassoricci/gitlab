<script>
import { GlTab, GlTabs } from '@gitlab/ui';
import ServiceAccountsList from './service_accounts_list.vue';
import IncubationBanner from './incubation_banner.vue';
import NoGcpProjects from './errors/no_gcp_projects.vue';
import RevokeAuth from './revoke_auth.vue';
import SectionDivider from './section_divider.vue';
import ServiceAccountsForm from './service_accounts_form.vue';
import ServiceAccountsList from './service_accounts_list.vue';

export default {
  components: {
    GcpError,
    GlTab,
    GlTabs,
    IncubationBanner,
    NoGcpProjects,
    RevokeAuth,
    SectionDivider,
    ServiceAccountsForm,
    ServiceAccountsList,
  },
  props: {
    screen: {
      required: true,
      type: String,
    },
    // gcp_error
    error: {
      type: String,
      required: false,
      default: '',
    },
    // service_accounts_form
    gcpProjects: {
      required: false,
      type: Array,
      default: () => [],
    },
    environments: {
      required: false,
      type: Array,
      default: () => [],
    },
    cancelPath: {
      required: false,
      type: String,
      default: '',
    },
    // home
    serviceAccounts: {
      type: Array,
      required: false,
      default: () => [],
    },
    createServiceAccountUrl: {
      type: String,
      required: false,
      default: '',
    },
    emptyIllustrationUrl: {
      type: String,
      required: false,
      default: '',
    },
  },
  methods: {
    feedbackUrl(template) {
      return `https://gitlab.com/gitlab-org/incubation-engineering/five-minute-production/meta/-/issues/new?issuable_template=${template}`;
    },
  },
};
</script>

<template>
  <div>
    <incubation-banner
      :share-feedback-url="feedbackUrl('general_feedback')"
      :report-bug-url="feedbackUrl('report_bug')"
      :feature-request-url="feedbackUrl('feature_request')"
    />

    <div v-if="screen === 'gcp_error'">
      <gcp-error :error="error" />
    </div>
    <div v-else-if="screen === 'no_gcp_projects'">
      <no-gcp-projects />
    </div>
    <div v-else-if="screen === 'service_accounts_form'">
      <service-accounts-form
        :cancel-path="cancelPath"
        :environments="environments"
        :gcp-projects="gcpProjects"
      />
    </div>
    <div v-else-if="screen === 'home'">
      <gl-tabs>
        <gl-tab :title="__('Configuration')">
          <service-accounts-list
            class="gl-mx-3"
            :list="serviceAccounts"
            :create-url="createServiceAccountUrl"
            :empty-illustration-url="emptyIllustrationUrl"
          />
          <section-divider />
          <revoke-auth />
        </gl-tab>
        <gl-tab :title="__('Deployments')" disabled />
        <gl-tab :title="__('Services')" disabled />
      </gl-tabs>
    </div>
  </div>
</template>
