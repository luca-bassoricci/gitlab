<script>
import { GlLink, GlIcon, GlButton, GlProgressBar } from '@gitlab/ui';

export default {
  name: 'StatisticsCard',
  components: { GlLink, GlIcon, GlButton, GlProgressBar },
  props: {
    description: {
      type: String,
      required: false,
      default: null,
    },
    helpLink: {
      type: String,
      required: false,
      default: null,
    },
    percentage: {
      type: Number,
      required: false,
      default: null,
    },
    purchaseButtonLink: {
      type: String,
      required: false,
      default: null,
    },
    purchaseButtonText: {
      type: String,
      required: false,
      default: null,
    },
    cssClass: {
      type: String,
      required: false,
      default: null,
    },
  },
};
</script>

<template>
  <div
    class="gl-bg-white gl-border-1 gl-border-gray-100 gl-border-solid gl-p-5 gl-rounded-base"
    :class="cssClass"
  >
    <div class="gl-display-flex gl-justify-content-space-between gl-mb-3">
      <slot></slot>
      <slot name="top-left">
        <div>
          <gl-button
            v-if="purchaseButtonLink && purchaseButtonText"
            :href="purchaseButtonLink"
            category="primary"
            variant="confirm"
          >
            {{ purchaseButtonText }}
          </gl-button>
        </div>
      </slot>
    </div>
    <slot name="footer">
      <p class="gl-font-weight-bold gl-mt-3">
        {{ description }}
        <gl-link
          v-if="helpLink"
          :href="helpLink"
          target="_blank"
          rel="noopener noreferrer nofollow"
          class="gl-ml-2"
        >
          <gl-icon name="question-o" />
        </gl-link>
      </p>
      <gl-progress-bar v-if="percentage" :value="percentage" />
    </slot>
  </div>
</template>
