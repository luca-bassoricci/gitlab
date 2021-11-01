<script>
import { GlCollapse, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import ReportItem from './report_item.vue';

export default {
  i18n: {
    heading: s__('Vulnerability|Evidence'),
  },
  components: {
    GlCollapse,
    GlIcon,
    ReportItem,
  },
  props: {
    details: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      showSection: true,
    };
  },
  computed: {
    hasDetails() {
      return this.details.length > 0;
    },
  },
  methods: {
    toggleShowSection() {
      this.showSection = !this.showSection;
    },
  },
};
</script>
<template>
  <section v-if="hasDetails">
    <header
      class="gl-display-inline-flex gl-align-items-center gl-font-size-h3 gl-cursor-pointer"
      @click="toggleShowSection"
    >
      <gl-icon name="angle-right" class="gl-mr-2" :class="{ 'gl-rotate-90': showSection }" />
      <h3 class="gl-my-0! gl-font-lg">
        {{ $options.i18n.heading }}
      </h3>
    </header>
    <gl-collapse :visible="showSection">
      <div class="generic-report-container" data-testid="reports">
        <template v-for="item in details">
          <div :key="item.name" class="generic-report-row" :data-testid="`report-row-${item.name}`">
            <strong class="generic-report-column">{{ item.name }}</strong>
            <div class="generic-report-column" data-testid="reportContent">
              <report-item :item="item" :data-testid="`report-item-${item.name}`" />
            </div>
          </div>
        </template>
      </div>
    </gl-collapse>
  </section>
</template>
