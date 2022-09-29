<script>
import { GlLoadingIcon, GlSprintf, GlTableLite } from '@gitlab/ui';
import { __ } from '~/locale';
import CiIconBadge from '~/vue_shared/components/ci_badge_link.vue';
import getManualJobs from '../../graphql/queries/get_manual_jobs.query.graphql';
import getPipelineSummary from '../../graphql/queries/get_pipeline_summary.query.graphql';
import ActionComponent from '../jobs_shared/action_component.vue';
import { getQueryHeaders } from '../graph/utils';

export default {
  components: {
    ActionComponent,
    CiIconBadge,
    GlLoadingIcon,
    GlSprintf,
    GlTableLite,
  },
  inject: ['fullPath', 'graphqlResourceEtag', 'pipelineIid'],
  data() {
    return {
      failedJobs: [],
    };
  },
  apollo: {
    manualJobs: {
      query: getManualJobs,
      context() {
        return getQueryHeaders(this.graphqlResourceEtag);
      },
      pollInterval: 10000,
      variables() {
        return {
          fullPath: this.fullPath,
          pipelineIid: this.pipelineIid,
        };
      },
      update(data) {
        return data?.project?.pipeline?.jobs?.nodes;
      },
    },
    pipeline: {
      query: getPipelineSummary,
      pollInterval: 10000,
      context() {
        return getQueryHeaders(this.graphqlResourceEtag);
      },
      variables() {
        return {
          fullPath: this.fullPath,
          pipelineIid: this.pipelineIid,
        };
      },
      update(data) {
        return data?.project?.pipeline;
      },
      result({ data }) {
        this.failedJobs = data?.project?.pipeline?.jobs?.nodes || [];
      },
      error(e) {
        console.log(e);
      },
    },
  },
  computed: {
    nonBlockingFailures() {
      return this.failedJobs.filter((job) => {
        return job.allowFailure;
      });
    },
    blockingFailures() {
      return this.failedJobs.filter((job) => {
        return !job.allowFailure;
      });
    },
    hasBlockingFailures() {
      return this.nbOfBlockingFailures > 0;
    },
    hasNonBlockingFailures() {
      return this.nbOfNonBlockingFailures > 0;
    },
    hasPipelineFinishedSuccessfully() {
      return this.pipeline?.status === 'SUCCESS';
    },
    isAttentionRequired() {
      return this.hasBlockingFailures || this.isBlocked;
    },
    isBlocked() {
      return this.pipeline?.status === 'MANUAL';
    },
    isLoading() {
      return this.$apollo.queries.pipeline.loading || this.$apollo.queries.manualJobs.loading;
    },
    nbOfBlockingFailures() {
      return this.blockingFailures.length;
    },
    nbOfNonBlockingFailures() {
      return this.nonBlockingFailures.length;
    },
    nbOfManuals() {
      return this.manualJobs.length;
    },
  },
  methods: {
    generateDuration(duration) {
      return duration ? __(`${duration} s`) : 'N/A';
    },
    showAction(job) {
      return job?.detailedStatus?.action?.path && job.userPermissions.updateBuild;
    },
  },
  failedJobsFields: [
    {
      key: 'name',
      label: __('Job name'),
      tdClass: 'gl-w-10p',
    },
    {
      key: 'stage.name',
      label: __('Stage'),
      tdClass: 'gl-vertical-align-middle! gl-w-5p',
    },
    {
      key: 'allowFailure',
      label: __('Allowed to fail'),
      tdClass: 'gl-vertical-align-middle! gl-w-5p',
    },
    {
      key: 'duration',
      label: __('Duration'),
      tdClass: 'gl-vertical-align-middle! gl-w-5p',
    },
    {
      key: 'isRetryable',
      label: __('Action'),
      tdClass: 'gl-relative gl-pl-0! gl-w-5p',
    },
  ],
  i18n: {
    attentionMessages: {
      failedJobs: __('You have %{nbOfFailures} failed jobs.'),
      failedJobsWarning: 'You have %{nbOfFailures} failed jobs that are allowed to fail.',
      blocked: __('Your pipeline is blocked due to %{nbOfManuals} pending manual jobs.'),
    },
    manual: __('Pending Manual Jobs'),
    noIssues: {
      whileRunning: __('No problems so far!'),
      finished: __('This pipeline has completed with no issues!'),
    },
    pipelineReportTitle: __('Pipeline report'),
    pipelineStatus: __('Pipeline status:'),
    summaryTitle: __('Pipeline Summary'),
    failedJobsTitle: __('Failed jobs'),
  },
  jobItemClasses: ['gl-pb-3', 'gl-font-lg'],
};
</script>

<template>
  <div>
    <gl-loading-icon v-if="isLoading" />
    <div v-else>
      <h2>{{ $options.i18n.pipelineReportTitle }}</h2>
      <ul>
        <li :class="$options.jobItemClasses">
          {{ $options.i18n.pipelineStatus }}
          <ci-icon-badge :status="pipeline.detailedStatus" />
        </li>
        <li v-if="isBlocked" :class="$options.jobItemClasses">
          <gl-sprintf :message="$options.i18n.attentionMessages.blocked">
            <template #nbOfManuals>
              {{ nbOfManuals }}
            </template>
          </gl-sprintf>
        </li>
        <li v-if="hasBlockingFailures" :class="$options.jobItemClasses">
          <gl-sprintf :message="$options.i18n.attentionMessages.failedJobs">
            <template #nbOfFailures>
              {{ nbOfBlockingFailures }}
            </template>
          </gl-sprintf>
        </li>
        <li v-if="hasNonBlockingFailures" :class="$options.jobItemClasses">
          <gl-sprintf :message="$options.i18n.attentionMessages.failedJobsWarning">
            <template #nbOfFailures>
              {{ nbOfNonBlockingFailures }}
            </template>
          </gl-sprintf>
        </li>
        <li v-if="hasPipelineFinishedSuccessfully" :class="$options.jobItemClasses">
          {{ $options.i18n.noIssues.finished }}
        </li>
      </ul>

      <div></div>
      <h3>{{ $options.i18n.manual }}</h3>
      <gl-table-lite :fields="$options.failedJobsFields" :items="manualJobs">
        <template #cell(duration)="{ item: { duration } }">
          {{ generateDuration(duration) }}
        </template>
        <template #cell(isRetryable)="{ item }">
          <action-component
            v-if="showAction(item)"
            class="gl-left-4"
            :action-icon="item.detailedStatus.action.icon"
            :link="item.detailedStatus.action.path"
            :tooltip-text="item.detailedStatus.action.title"
          />
        </template>
      </gl-table-lite>

      <h3>{{ $options.i18n.failedJobsTitle }}</h3>
      <gl-table-lite :fields="$options.failedJobsFields" :items="failedJobs">
        <template #cell(duration)="{ item: { duration } }">
          {{ generateDuration(duration) }}
        </template>
        <template #cell(isRetryable)="{ item }">
          <action-component
            v-if="showAction(item)"
            class="gl-left-4"
            :action-icon="item.detailedStatus.action.icon"
            :link="item.detailedStatus.action.path"
            :tooltip-text="item.detailedStatus.action.title"
          />
        </template>
      </gl-table-lite>
    </div>
  </div>
</template>
