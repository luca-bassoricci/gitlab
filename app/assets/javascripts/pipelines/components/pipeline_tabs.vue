<script>
import { GlBadge, GlTabs, GlTab } from '@gitlab/ui';
import { __ } from '~/locale';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import {
  failedJobsTabName,
  jobsTabName,
  needsTabName,
  pipelineTabName,
  summaryTabName,
  testReportTabName,
} from '../constants';
import PipelineGraphWrapper from './graph/graph_component_wrapper.vue';
import PipelineSummary from './summary/pipeline_summary.vue';
import Dag from './dag/dag.vue';
import FailedJobsApp from './jobs/failed_jobs_app.vue';
import JobsApp from './jobs/jobs_app.vue';
import TestReports from './test_reports/test_reports.vue';

export default {
  i18n: {
    tabs: {
      failedJobsTitle: __('Failed Jobs'),
      jobsTitle: __('Jobs'),
      needsTitle: __('Needs'),
      pipelineTitle: __('Pipeline'),
      summaryTitle: __('Summary'),
      testsTitle: __('Tests'),
    },
  },
  tabNames: {
    pipeline: pipelineTabName,
    needs: needsTabName,
    jobs: jobsTabName,
    failures: failedJobsTabName,
    tests: testReportTabName,
    summary: summaryTabName,
  },
  components: {
    Dag,
    GlBadge,
    GlTab,
    GlTabs,
    JobsApp,
    FailedJobsApp,
    PipelineGraphWrapper,
    PipelineSummary,
    TestReports,
  },
  mixins: [glFeatureFlagMixin()],

  inject: [
    'defaultTabValue',
    'failedJobsCount',
    'failedJobsSummary',
    'totalJobCount',
    'testsCount',
  ],
  computed: {
    showFailedJobsTab() {
      return this.failedJobsCount > 0;
    },
    showSummaryTab() {
      return this.glFeatures.pipelineSummary;
    },
  },
  methods: {
    isActive(tabName) {
      return tabName === this.defaultTabValue;
    },
  },
};
</script>

<template>
  <gl-tabs>
    <gl-tab
      v-if="showSummaryTab"
      ref="summaryTab"
      :title="$options.i18n.tabs.summaryTitle"
      data-testid="summary-tab"
      lazy
    >
      <pipeline-summary />
    </gl-tab>
    <gl-tab
      ref="pipelineTab"
      :active="isActive($options.tabNames.pipeline)"
      :title="$options.i18n.tabs.pipelineTitle"
      data-testid="pipeline-tab"
      lazy
    >
      <pipeline-graph-wrapper />
    </gl-tab>
    <gl-tab
      ref="dagTab"
      :title="$options.i18n.tabs.needsTitle"
      :active="isActive($options.tabNames.needs)"
      data-testid="dag-tab"
      lazy
    >
      <dag />
    </gl-tab>
    <gl-tab :active="isActive($options.tabNames.jobs)" data-testid="jobs-tab" lazy>
      <template #title>
        <span class="gl-mr-2">{{ $options.i18n.tabs.jobsTitle }}</span>
        <gl-badge size="sm" data-testid="builds-counter">{{ totalJobCount }}</gl-badge>
      </template>
      <jobs-app />
    </gl-tab>
    <gl-tab
      v-if="showFailedJobsTab"
      :title="$options.i18n.tabs.failedJobsTitle"
      :active="isActive($options.tabNames.failures)"
      data-testid="failed-jobs-tab"
      lazy
    >
      <template #title>
        <span class="gl-mr-2">{{ $options.i18n.tabs.failedJobsTitle }}</span>
        <gl-badge size="sm" data-testid="failed-builds-counter">{{ failedJobsCount }}</gl-badge>
      </template>
      <failed-jobs-app :failed-jobs-summary="failedJobsSummary" />
    </gl-tab>
    <gl-tab :active="isActive($options.tabNames.tests)" data-testid="tests-tab" lazy>
      <template #title>
        <span class="gl-mr-2">{{ $options.i18n.tabs.testsTitle }}</span>
        <gl-badge size="sm" data-testid="tests-counter">{{ testsCount }}</gl-badge>
      </template>
      <test-reports />
    </gl-tab>
    <slot></slot>
  </gl-tabs>
</template>
