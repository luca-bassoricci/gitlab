<script>
import { GlToggle } from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';
import { severityFilter, standardScannerFilter } from 'ee/security_dashboard/helpers';
import { DISMISSAL_STATES } from 'ee/security_dashboard/store/modules/filters/constants';
import { s__ } from '~/locale';
import StandardFilter from '../shared/filters/standard_filter.vue';

export default {
  i18n: {
    toggleLabel: s__('SecurityReports|Hide dismissed'),
  },
  components: {
    StandardFilter,
    GlToggle,
  },
  data() {
    return {
      filterConfigs: [severityFilter, standardScannerFilter],
    };
  },
  computed: {
    ...mapState('filters', ['filters']),
    hideDismissed: {
      set(isHidden) {
        this.setHideDismissed(isHidden);
      },
      get() {
        return this.filters.scope === DISMISSAL_STATES.DISMISSED;
      },
    },
  },
  methods: {
    ...mapActions('filters', ['setFilter', 'setHideDismissed']),
  },
};
</script>

<template>
  <div class="dashboard-filters border-bottom bg-gray-light">
    <div class="row mx-0 p-2">
      <standard-filter
        v-for="filter in filterConfigs"
        :key="filter.id"
        class="col-sm-6 col-md-4 col-lg-2 p-2 js-filter"
        :filter="filter"
        :data-testid="filter.id"
        @filter-changed="setFilter"
      />
      <div class="gl-display-flex ml-lg-auto p-2">
        <slot name="buttons"></slot>
        <div class="pl-md-6 gl-pt-1">
          <gl-toggle v-model="hideDismissed" :label="$options.i18n.toggleLabel" />
        </div>
      </div>
    </div>
  </div>
</template>
