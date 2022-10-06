<script>
import { GlLoadingIcon, GlSprintf, GlTableLite } from '@gitlab/ui';
import { __ } from '~/locale';
import CiIconBadge from '~/vue_shared/components/ci_badge_link.vue';
import getFailedJobs from '../../graphql/queries/get_failed_jobs.query.graphql';
import getManualJobs from '../../graphql/queries/get_manual_jobs.query.graphql';
import getPipelineSummary from '../../graphql/queries/get_pipeline_summary.query.graphql';
import ActionComponent from '../jobs_shared/action_component.vue';
import { getQueryHeaders } from '../graph/utils';
import PipelineProgressBar from './pipeline_progress_bar.vue';

export default {
  components: {
    ActionComponent,
    CiIconBadge,
    GlLoadingIcon,
    GlSprintf,
    GlTableLite,
    PipelineProgressBar,
  },

  inject: ['fullPath', 'graphqlResourceEtag', 'pipelineIid'],
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
    failedJobs: {
      query: getFailedJobs,
      pollInterval: 10000,
      variables() {
        return {
          fullPath: this.fullPath,
          pipelineIid: this.pipelineIid,
        };
      },
      update(data) {
        return data?.project?.pipeline?.jobs?.nodes || [];
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
    pipelineProgress() {
      return [
        { color: 'red', title: '10 Failed Jobs', value: 10 },
        { color: 'green', title: '50 Successful Jobs', value: 40 },
        { color: 'blue', title: '20 Running jobs', value: 20 },
      ];
    },
  },
  methods: {
    generateDuration(duration) {
      return duration ? __(`${duration} s`) : 'N/A';
    },
    refetchFailedJobs() {
      this.$apollo.queries.pipeline.refetch();
    },
    refetchManualJobs() {
      this.$apollo.queries.manualJobs.refetch();
    },
    showAction(job) {
      return job?.detailedStatus?.action?.path && job.userPermissions.updateBuild;
    },
  },
  jobsFields: [
    {
      key: 'name',
      label: __('Job name'),
      tdClass: 'gl-w-10p',
    },
    {
      key: 'status',
      label: 'Status',
      tdClass: 'gl-w-10p',
    },
    {
      key: 'stage.name',
      label: __('Stage'),
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
    allJobs: __('All jobs'),
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
      <pipeline-progress-bar :values="pipelineProgress" :duration="pipeline.duration" />
      <ul class="gl-mt-6">
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
      <gl-table-lite :fields="$options.jobsFields" :items="manualJobs">
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
            @click="refetchManualJobs"
          />
        </template>
      </gl-table-lite>

      <h3>{{ $options.i18n.failedJobsTitle }}</h3>
      <gl-table-lite :fields="$options.jobsFields" :items="failedJobs">
        <template #cell(status)="{ item }">
          <ci-icon-badge :size="24" :status="item.detailedStatus" class="gl-line-height-0" />
        </template>
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
            @click="refetchFailedJobs"
          />
        </template>
      </gl-table-lite>
    </div>
  </div>
</template>
