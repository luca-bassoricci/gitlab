<script>
/* eslint-disable @gitlab/vue-require-i18n-strings */
import {
  GlBadge,
  GlButton,
  GlFilteredSearch,
  GlIcon,
  GlSprintf,
  GlSkeletonLoader,
  GlTooltipDirective,
} from '@gitlab/ui';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import getRunnersQuery from '../graphql/get_runners.query.graphql';

export default {
  components: {
    GlBadge,
    GlButton,
    GlFilteredSearch,
    GlIcon,
    GlSprintf,
    GlSkeletonLoader,
    TimeAgo,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  data() {
    return {
      search: [],
      runners: [],
    };
  },
  apollo: {
    runners: {
      query: getRunnersQuery,
      update(data) {
        return data.runners;
      },
    },
  },
  methods: {
    runnerUrl(id) {
      return `${gon.relative_url_root}/admin/runners/${id}`;
    },
  },
};
</script>
<template>
  <div>
    <div class="gl-display-flex gl-py-3">
      <div class="gl-flex-grow-1 gl-flex-shrink-1 gl-mr-3"></div>
      <div class="gl-flex-grow-1 gl-flex-shrink-0 gl-text-right">
        <gl-button category="primary" variant="confirm">
          {{ __('Register new runner') }}
        </gl-button>
      </div>
    </div>
    <div
      style="
        background-color: #fafafa;
        border-top: 1px solid #eaeaea;
        border-bottom: 1px solid #eaeaea;
      "
      class="gl-p-4"
    >
      <gl-filtered-search v-model="search" :available-tokens="[]" />
    </div>

    <div v-if="$apollo.loading && !runners.length" class="gl-px-3 gl-py-3 gl-px-4">
      <gl-skeleton-loader />
    </div>
    <ul v-else class="content-list">
      <li v-for="runner in runners" :key="runner.id" class="gl-px-3 gl-py-3">
        <div class="gl-display-flex gl-px-4">
          <div class="gl-flex-grow-1 gl-flex-shrink-1 gl-mr-3">
            <div class="gl-font-weight-bold">
              <a class="gl-text-body" :href="runnerUrl(runner.id)">
                #{{ runner.id }} ({{ runner.shortSha }})
              </a>
            </div>
            <div>
              <span class="gl-text-gray-500">
                {{ runner.description }}
                ·
                {{ runner.version }}
                ·
                {{ runner.ipAddress }}
              </span>
              <!-- runner type -->
              <gl-badge
                v-if="runner.runnerType == 'INSTANCE'"
                v-gl-tooltip
                :title="__('Runs jobs from all unassigned projects.')"
                size="sm"
                variant="success"
              >
                {{ s__('Runners|shared') }}
              </gl-badge>
              <gl-badge
                v-else-if="runner.runnerType == 'GROUP'"
                v-gl-tooltip
                :title="__('Runs jobs from all unassigned projects in its group.')"
                size="sm"
                variant="success"
              >
                {{ s__('Runners|group') }}
              </gl-badge>
              <gl-badge
                v-else
                v-gl-tooltip
                :title="__('Runs jobs from assigned projects.')"
                variant="info"
                size="sm"
              >
                {{ s__('Runners|specific') }}
              </gl-badge>

              <!-- locked -->
              <gl-badge
                v-if="runner.locked"
                v-gl-tooltip
                :title="__('Cannot be assigned to other projects.')"
                size="sm"
                variant="warning"
              >
                {{ s__('Runners|locked') }}
              </gl-badge>

              <!-- paused -->
              <gl-badge
                v-if="!runner.active"
                v-gl-tooltip
                :title="__('Not available to run jobs.')"
                size="sm"
                variant="danger"
              >
                {{ s__('Runners|paused') }}
              </gl-badge>

              <!-- tag -->
              <template v-for="tag in runner.tagList">
                <gl-badge :key="tag" size="sm">
                  {{ tag }}
                </gl-badge>
                {{ ' ' }}
              </template>
            </div>
          </div>
          <div
            class="gl-display-none gl-md-display-block gl-flex-grow-1 gl-flex-shrink-0 gl-text-right gl-text-gray-500"
          >
            <div>
              <!--groups -->
              <span v-gl-tooltip :title="__('Groups')">
                <gl-icon name="group" />&nbsp;<span>{{ '0' }}</span>
              </span>
              <!--jobs -->
              <span v-gl-tooltip :title="__('Projects')">
                <gl-icon name="project" />&nbsp;<span>{{ runner.projectsCount }}</span>
              </span>
              <!--jobs -->
              <span v-gl-tooltip :title="__('Jobs')">
                <gl-icon name="check-circle" />&nbsp;<span>{{ runner.jobsCount }}</span>
              </span>
            </div>

            <div>
              <gl-icon
                v-if="runner.status == 'OFFLINE'"
                v-gl-tooltip
                :title="s__('Runners|Runner is offline')"
                name="warning-solid"
              />
              <span v-if="runner.lastContactAt">
                <gl-sprintf :message="s__('Runners|last contacted %{timeAgo}')">
                  <template #timeAgo>
                    <time-ago :time="runner.lastContactAt" />
                  </template>
                </gl-sprintf>
              </span>
              <span v-else>{{ s__('Runners|never contacted') }}</span>
            </div>
          </div>
        </div>
      </li>
    </ul>
  </div>
</template>
