<script>
import { GlTooltipDirective } from '@gitlab/ui';
import { DEVOPS_ADOPTION_STRINGS } from '../constants';

const {
  tableCell: { trueText, falseText },
} = DEVOPS_ADOPTION_STRINGS;

export default {
  name: 'DevopsAdoptionTableCellFlag',
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    enabled: {
      type: Boolean,
      required: true,
    },
    variant: {
      type: String,
      required: false,
      default: 'default',
    },
  },
  computed: {
    tooltipText() {
      return this.enabled ? trueText : falseText;
    },
  },
};
</script>
<template>
  <span
    v-gl-tooltip.hover="tooltipText"
    class="circle"
    :class="{ [`circle-enabled-${variant}`]: enabled }"
  ></span>
</template>
