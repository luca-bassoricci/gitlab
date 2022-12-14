<script>
import { GlAlert, GlTabs, GlTab } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import dateformat from 'dateformat';
import DevopsScore from '~/analytics/devops_report/components/devops_score.vue';
import API from '~/api';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { mergeUrlParams, updateHistory, getParameterValues } from '~/lib/utils/url_utility';
import {
  DEVOPS_ADOPTION_STRINGS,
  DEVOPS_ADOPTION_ERROR_KEYS,
  DATE_TIME_FORMAT,
  DEFAULT_POLLING_INTERVAL,
  DEVOPS_ADOPTION_GROUP_LEVEL_LABEL,
  DEVOPS_ADOPTION_TABLE_CONFIGURATION,
  TRACK_ADOPTION_TAB_CLICK_EVENT,
  TRACK_DEVOPS_SCORE_TAB_CLICK_EVENT,
} from '../constants';
import bulkEnableDevopsAdoptionNamespacesMutation from '../graphql/mutations/bulk_enable_devops_adoption_namespaces.mutation.graphql';
import devopsAdoptionEnabledNamespacesQuery from '../graphql/queries/devops_adoption_enabled_namespaces.query.graphql';
import getGroupsQuery from '../graphql/queries/get_groups.query.graphql';
import { addSegmentsToCache, deleteSegmentsFromCache } from '../utils/cache_updates';
import { shouldPollTableData } from '../utils/helpers';
import DevopsAdoptionAddDropdown from './devops_adoption_add_dropdown.vue';
import DevopsAdoptionSection from './devops_adoption_section.vue';

export default {
  name: 'DevopsAdoptionApp',
  components: {
    GlAlert,
    DevopsAdoptionAddDropdown,
    DevopsAdoptionSection,
    DevopsScore,
    GlTabs,
    GlTab,
  },
  inject: {
    isGroup: {
      default: false,
    },
    groupGid: {
      default: null,
    },
    devopsScoreMetrics: {
      default: null,
    },
    devopsReportDocsPath: {
      default: '',
    },
    noDataImagePath: {
      default: '',
    },
  },
  i18n: {
    groupLevelLabel: DEVOPS_ADOPTION_GROUP_LEVEL_LABEL,
    ...DEVOPS_ADOPTION_STRINGS.app,
  },
  trackDevopsTabClickEvent: TRACK_ADOPTION_TAB_CLICK_EVENT,
  trackDevopsScoreTabClickEvent: TRACK_DEVOPS_SCORE_TAB_CLICK_EVENT,
  devopsAdoptionTableConfiguration: DEVOPS_ADOPTION_TABLE_CONFIGURATION,
  data() {
    return {
      hasSubgroups: undefined,
      isLoadingGroups: false,
      isLoadingEnableGroup: false,
      requestCount: 0,
      openModal: false,
      errors: {
        [DEVOPS_ADOPTION_ERROR_KEYS.groups]: false,
        [DEVOPS_ADOPTION_ERROR_KEYS.segments]: false,
        [DEVOPS_ADOPTION_ERROR_KEYS.addSegment]: false,
      },
      groups: {
        nodes: [],
        pageInfo: null,
      },
      pollingTableData: null,
      segmentsQueryVariables: {
        displayNamespaceId: this.isGroup ? this.groupGid : null,
      },
      adoptionTabClicked: false,
      devopsScoreTabClicked: false,
      selectedTab: 0,
    };
  },
  apollo: {
    devopsAdoptionEnabledNamespaces: {
      query: devopsAdoptionEnabledNamespacesQuery,
      context: {
        isSingleRequest: true,
      },
      variables() {
        return this.segmentsQueryVariables;
      },
      result({ data }) {
        if (this.isGroup) {
          const groupEnabled = data.devopsAdoptionEnabledNamespaces.nodes.some(
            ({ namespace: { id } }) => id === this.groupGid,
          );

          if (!groupEnabled) {
            this.enableGroup();
          }
        }
      },
      error(error) {
        this.handleError(DEVOPS_ADOPTION_ERROR_KEYS.segments, error);
      },
    },
  },
  computed: {
    isAdmin() {
      return !this.isGroup;
    },
    hasGroupData() {
      return Boolean(this.groups?.nodes?.length);
    },
    hasSegmentsData() {
      return Boolean(this.devopsAdoptionEnabledNamespaces?.nodes?.length);
    },
    hasLoadingError() {
      return Object.values(this.errors).some((error) => error === true);
    },
    timestamp() {
      return dateformat(
        this.devopsAdoptionEnabledNamespaces?.nodes[0]?.latestSnapshot?.recordedAt,
        DATE_TIME_FORMAT,
      );
    },
    isLoading() {
      return (
        this.isLoadingGroups ||
        this.isLoadingEnableGroup ||
        this.$apollo.queries.devopsAdoptionEnabledNamespaces.loading
      );
    },
    isLoadingAdoptionData() {
      return (
        this.isLoadingEnableGroup || this.$apollo.queries.devopsAdoptionEnabledNamespaces.loading
      );
    },
    tabIndexValues() {
      const tabs = this.$options.devopsAdoptionTableConfiguration.map((item) => item.tab);

      return this.isGroup ? tabs : [...tabs, 'devops-score'];
    },
    availableGroups() {
      return this.groups?.nodes || [];
    },
    enabledNamespaces() {
      return this.devopsAdoptionEnabledNamespaces?.nodes || [];
    },
    disabledGroupNodes() {
      const enabledNamespaceIds = this.enabledNamespaces.map((group) =>
        getIdFromGraphQLId(group.namespace.id),
      );

      return this.availableGroups.filter((group) => !enabledNamespaceIds.includes(group.id));
    },
  },
  created() {
    this.fetchGroups();
    this.selectTab();
    this.startPollingTableData();
  },
  beforeDestroy() {
    clearInterval(this.pollingTableData);
  },
  methods: {
    openAddRemoveModal() {
      this.$refs.addRemoveModal.openModal();
    },
    enableGroup() {
      this.isLoadingEnableGroup = true;

      this.$apollo
        .mutate({
          mutation: bulkEnableDevopsAdoptionNamespacesMutation,
          variables: {
            namespaceIds: [this.groupGid],
          },
          update: (store, { data }) => {
            const {
              bulkEnableDevopsAdoptionNamespaces: { enabledNamespaces, errors },
            } = data;

            if (errors.length) {
              this.handleError(DEVOPS_ADOPTION_ERROR_KEYS.addSegment, errors);
            } else {
              this.addSegmentsToCache(enabledNamespaces);
            }
          },
        })
        .catch((error) => {
          this.handleError(DEVOPS_ADOPTION_ERROR_KEYS.addSegment, error);
        })
        .finally(() => {
          this.isLoadingEnableGroup = false;
        });
    },
    pollTableData() {
      const shouldPoll = shouldPollTableData({
        segments: this.devopsAdoptionEnabledNamespaces.nodes,
        timestamp: this.devopsAdoptionEnabledNamespaces?.nodes[0]?.latestSnapshot?.recordedAt,
        openModal: this.openModal,
      });

      if (shouldPoll) {
        this.$apollo.queries.devopsAdoptionEnabledNamespaces.refetch();
      }
    },
    trackModalOpenState(state) {
      this.openModal = state;
    },
    startPollingTableData() {
      this.pollingTableData = setInterval(this.pollTableData, DEFAULT_POLLING_INTERVAL);
    },
    handleError(key, error) {
      this.errors[key] = true;
      Sentry.captureException(error);
    },
    fetchGroups(searchTerm = '') {
      this.searchTerm = searchTerm;
      this.isLoadingGroups = true;

      this.$apollo
        .query({
          query: getGroupsQuery,
          context: {
            isSingleRequest: true,
          },
          variables: {
            search: searchTerm,
          },
        })
        .then(({ data }) => {
          this.groups = data.groups;

          if (this.hasSubgroups === undefined) {
            this.hasSubgroups = this.groups?.nodes?.length > 0;
          }

          this.isLoadingGroups = false;
        })
        .catch((error) => this.handleError(DEVOPS_ADOPTION_ERROR_KEYS.groups, error));
    },
    addSegmentsToCache(segments) {
      const { cache } = this.$apollo.getClient();

      addSegmentsToCache(cache, segments, this.segmentsQueryVariables);
    },
    deleteSegmentsFromCache(ids) {
      const { cache } = this.$apollo.getClient();

      deleteSegmentsFromCache(cache, ids, this.segmentsQueryVariables);
    },
    selectTab() {
      const [value] = getParameterValues('tab');

      if (value) {
        this.selectedTab = this.tabIndexValues.indexOf(value);
      }
    },
    onTabChange(index) {
      if (index > 0) {
        if (index !== this.selectedTab) {
          const path = mergeUrlParams(
            { tab: this.tabIndexValues[index] },
            window.location.pathname,
          );
          updateHistory({ url: path, title: window.title });
        }
      } else {
        updateHistory({ url: window.location.pathname, title: window.title });
      }

      this.selectedTab = index;
    },
    trackDevopsScoreTabClick() {
      if (!this.devopsScoreTabClicked) {
        API.trackRedisHllUserEvent(this.$options.trackDevopsScoreTabClickEvent);
        this.devopsScoreTabClicked = true;
      }
    },
    trackDevopsTabClick() {
      if (!this.adoptionTabClicked) {
        API.trackRedisHllUserEvent(this.$options.trackDevopsTabClickEvent);
        this.adoptionTabClicked = true;
      }
    },
  },
};
</script>
<template>
  <div>
    <gl-tabs :value="selectedTab" @input="onTabChange">
      <gl-tab
        v-for="tab in $options.devopsAdoptionTableConfiguration"
        :key="tab.title"
        data-testid="devops-adoption-tab"
        @click="trackDevopsTabClick"
      >
        <template #title>{{ tab.title }}</template>
        <div v-if="hasLoadingError">
          <template v-for="(error, key) in errors">
            <gl-alert v-if="error" :key="key" variant="danger" :dismissible="false" class="gl-mt-3">
              {{ $options.i18n[key] }}
            </gl-alert>
          </template>
        </div>

        <devops-adoption-section
          v-else
          :is-loading="isLoadingAdoptionData"
          :has-segments-data="hasSegmentsData"
          :timestamp="timestamp"
          :has-group-data="hasGroupData"
          :cols="tab.cols"
          :segments="devopsAdoptionEnabledNamespaces"
          :search-term="searchTerm"
          :disabled-group-nodes="disabledGroupNodes"
          :is-loading-groups="isLoadingGroups"
          :has-subgroups="hasSubgroups"
          @segmentsRemoved="deleteSegmentsFromCache"
          @fetchGroups="fetchGroups"
          @segmentsAdded="addSegmentsToCache"
          @trackModalOpenState="trackModalOpenState"
        />
      </gl-tab>

      <gl-tab v-if="isAdmin" data-testid="devops-score-tab" @click="trackDevopsScoreTabClick">
        <template #title>{{ s__('DevopsReport|DevOps Score') }}</template>
        <devops-score />
      </gl-tab>

      <template #tabs-end>
        <span
          class="nav-item gl-align-self-center gl-flex-grow-1 gl-display-none gl-md-display-block"
          align="right"
        >
          <devops-adoption-add-dropdown
            :search-term="searchTerm"
            :groups="disabledGroupNodes"
            :is-loading-groups="isLoadingGroups"
            :has-subgroups="hasSubgroups"
            @fetchGroups="fetchGroups"
            @segmentsAdded="addSegmentsToCache"
          />
        </span>
      </template>
    </gl-tabs>
  </div>
</template>
