<script>
import Cookies from 'js-cookie';
import { GlTabs, GlTab, GlButton } from '@gitlab/ui';
import { __ } from '~/locale';
import MergeRequestsGrid from './merge_requests/grid.vue';
import EmptyState from './empty_state.vue';
import MergeCommitsExportButton from './merge_requests/merge_commits_export_button.vue';
import { COMPLIANCE_TAB_COOKIE_KEY } from '../constants';
import Api from '~/api';
import axios from '~/lib/utils/axios_utils';
import Poll from '~/lib/utils/poll';

let eTagPoll;

export default {
  name: 'ComplianceDashboard',
  components: {
    MergeRequestsGrid,
    EmptyState,
    GlTab,
    GlTabs,
    MergeCommitsExportButton,
    GlButton,
  },
  props: {
    emptyStateSvgPath: {
      type: String,
      required: true,
    },
    mergeRequests: {
      type: Array,
      required: true,
    },
    isLastPage: {
      type: Boolean,
      required: false,
      default: false,
    },
    mergeCommitsCsvExportPath: {
      type: String,
      required: false,
      default: '',
    },
    downloadExportCsvPath: {
      type: String,
      required: true,
      default: '',
    },
    exportStatusCsvPath: {
      type: String,
      required: true,
      default: '',
    },
  },
  data() {
    return {
      showDownloadButton: false,
    };
  },
  computed: {
    hasMergeRequests() {
      return this.mergeRequests.length > 0;
    },
    hasMergeCommitsCsvExportPath() {
      return this.mergeCommitsCsvExportPath !== '';
    },
  },
  mounted() {
    this.poll();
  },
  methods: {
    showTabs() {
      return Cookies.get(COMPLIANCE_TAB_COOKIE_KEY) === 'true';
    },
    isExportReady() {
      return this.showDownloadButton == true;
    },
    fetchCsvExportStatus() {
      return axios.get(this.exportStatusCsvPath);
    },
    poll() {
      this.showDownloadButton = false;

      eTagPoll = new Poll({
        resource: {
          poll: () => {
            return axios.get(this.exportStatusCsvPath);
          },
        },
        method: 'poll',
        successCallback: ({ data }) => this.pollSuccessCallBack(eTagPoll, data),
        errorCallback: ()  => { console.log('errorCallback') },
      });

      eTagPoll.makeDelayedRequest(2500);
    },
    pollSuccessCallBack(eTagPoll, data) {
      if (data.status === 'present') {
        console.log('data present')
        this.showDownloadButton = true;
        eTagPoll.stop();
      }
    }
  },
  strings: {
    heading: __('Compliance Dashboard'),
    subheading: __('Here you will find recent merge request activity'),
    mergeRequestsTabLabel: __('Merge Requests'),
    downloadCsvButtonText: __('Download report'),
  },
};
</script>

<template>
  <div v-if="hasMergeRequests" class="compliance-dashboard">
    <header>
      <div class="gl-mt-5 d-flex">
        <h4 class="gl-flex-grow-1 gl-my-0">{{ $options.strings.heading }}</h4>
        <gl-button
              v-if="this.isExportReady()"
              :href="downloadExportCsvPath"
              class="gl-align-self-center download-csv"
        >
          {{ $options.strings.downloadCsvButtonText }}
        </gl-button>
        <merge-commits-export-button
          :merge-commits-csv-export-path="mergeCommitsCsvExportPath"
        />
      </div>
      <p>{{ $options.strings.subheading }}</p>
    </header>

    <gl-tabs v-if="showTabs()">
      <gl-tab>
        <template #title>
          <span>{{ $options.strings.mergeRequestsTabLabel }}</span>
        </template>
        <merge-requests-grid :merge-requests="mergeRequests" :is-last-page="isLastPage" />
      </gl-tab>
    </gl-tabs>
    <merge-requests-grid v-else :merge-requests="mergeRequests" :is-last-page="isLastPage" />
  </div>
  <empty-state v-else :image-path="emptyStateSvgPath" />
</template>

<style scoped>
.download-csv {
  margin-right: 10px;
}
</style>
