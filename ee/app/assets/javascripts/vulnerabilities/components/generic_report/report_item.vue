<script>
import { REPORT_COMPONENTS } from './types/constants';

export default {
  components: {
    ...REPORT_COMPONENTS,
  },
  props: {
    item: {
      type: Object,
      required: true,
    },
  },
};
</script>
<template>
  <component :is="item.type" v-bind="item" data-testid="reportComponent" />
</template>
