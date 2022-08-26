<script>
import { GlFilteredSearchToken, GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlFilteredSearchToken,
    GlIcon,
  },
  props: {
    config: {
      type: Object,
      required: true,
    },
    value: {
      type: Object,
      required: true,
    },
  },
  computed: {
    activeTitle() {
      return {
          text: this.value.data,
          value: this.value.data,
        }
    },
  },
};
</script>

<template>
  <gl-filtered-search-token v-bind="{ ...$props, ...$attrs }" v-on="$listeners">
    <template #view>
      <div class="gl-display-flex gl-align-items-center">
        <div class="">
          <gl-icon name="title" class="gl-mr-2 gl-display-block" />
        </div>
        <span>{{ activeTitle.text }}</span>
      </div>
    </template>
  </gl-filtered-search-token>
</template>
