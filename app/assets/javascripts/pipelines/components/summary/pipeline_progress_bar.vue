<script>
import { GlTooltipDirective } from '@gitlab/ui';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    duration: {
      required: true,
      type: Number,
    },
    values: {
      required: true,
      type: Array,
    },
  },
  computed: {
    pengingJobsTitle() {
      return `40 created jobs`;
    },
  },
  methods: {
    createClasses(item) {
      const classes = [];

      if (item.color === 'red') {
        classes.push('gl-bg-red-200');
      } else if (item.color === 'green') {
        classes.push('gl-bg-green-200');
      } else {
        classes.push('gl-bg-blue-200');
      }

      classes.push(`gl-w-${item.value}p`);

      return classes;
    },
  },
};
</script>
<template>
  <div class="gl--flex-center gl-flex-direction-column">
    <div
      class="gl-w-full gl-display-flex gl-h-6 gl-overflow-hidden gl-line-height-0 gl-bg-gray-50 gl-rounded-6"
    >
      <div
        v-for="item in values"
        :key="item.title"
        v-gl-tooltip
        :class="createClasses(item)"
        :title="item.title"
      ></div>
      <div v-gl-tooltip class="gl-bg-gray-50 gl-w-20p" :title="pengingJobsTitle"></div>
    </div>
    <span class="gl-mt-2 gl-text-gray-200">Duration: {{ duration }} seconds</span>
    <span class="gl-mt-2 gl-text-gray-200">Estimate remaining: 40 seconds</span>
  </div>
</template>
