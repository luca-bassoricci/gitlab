<script>
import { GlLoadingIcon, GlSprintf } from '@gitlab/ui';
import { TABLE_HEADER_TEXT } from '../constants';
import DevopsAdoptionAddDropdown from './devops_adoption_add_dropdown.vue';
import DevopsAdoptionEmptyState from './devops_adoption_empty_state.vue';
import DevopsAdoptionTable from './devops_adoption_table.vue';

export default {
  components: {
    DevopsAdoptionTable,
    GlLoadingIcon,
    GlSprintf,
    DevopsAdoptionEmptyState,
    DevopsAdoptionAddDropdown,
  },
  i18n: {
    tableHeaderText: TABLE_HEADER_TEXT,
  },
  props: {
    isLoading: {
      type: Boolean,
      required: true,
    },
    hasSegmentsData: {
      type: Boolean,
      required: true,
    },
    timestamp: {
      type: String,
      required: true,
    },
    hasGroupData: {
      type: Boolean,
      required: true,
    },
    cols: {
      type: Array,
      required: true,
    },
    segments: {
      type: Object,
      required: false,
      default: () => {},
    },
    disabledGroupNodes: {
      type: Array,
      required: true,
    },
    searchTerm: {
      type: String,
      required: true,
    },
    isLoadingGroups: {
      type: Boolean,
      required: true,
    },
    hasSubgroups: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
};
</script>
<template>
  <gl-loading-icon v-if="isLoading" size="md" class="gl-my-5" />
  <div v-else-if="hasSegmentsData" class="gl-mt-3">
    <div class="gl-my-3" data-testid="tableHeader">
      <span class="gl-text-gray-400">
        <gl-sprintf :message="$options.i18n.tableHeaderText">
          <template #timestamp>{{ timestamp }}</template>
        </gl-sprintf>
      </span>

      <devops-adoption-add-dropdown
        class="gl-mt-4 gl-mb-3 gl-md-display-none"
        :search-term="searchTerm"
        :groups="disabledGroupNodes"
        :is-loading-groups="isLoadingGroups"
        :has-subgroups="hasSubgroups"
        @fetchGroups="$emit('fetchGroups', $event)"
        @segmentsAdded="$emit('segmentsAdded', $event)"
        @trackModalOpenState="$emit('trackModalOpenState', $event)"
      />
    </div>
    <devops-adoption-table
      :cols="cols"
      :segments="segments.nodes"
      @segmentsRemoved="$emit('segmentsRemoved', $event)"
      @trackModalOpenState="$emit('trackModalOpenState', $event)"
    />
  </div>
  <devops-adoption-empty-state v-else :has-groups-data="hasGroupData" />
</template>
