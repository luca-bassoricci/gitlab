<script>
import { GlAlert } from '@gitlab/ui';

export default {
  components: { GlAlert },
  props: {
    title: {
      type: String,
      required: true,
    },
    description: {
      type: String,
      required: true,
    },
    primaryButtonText: {
      type: String,
      required: false,
      default: null,
    },
    primaryButtonLink: {
      type: String,
      required: false,
      default: null,
    },
    error: {
      type: String,
      required: false,
      default: null,
    },
  },
};
</script>

<template>
  <gl-alert :dismissible='false'
            variant='warning'
            :title='title'
            :primary-button-text='primaryButtonText'
            :primary-button-link='primaryButtonLink'>
    {{ description }}
    <blockquote v-if='error' class='gl-mt-5'>
      <code>{{ error }}</code>
    </blockquote>
  </gl-alert>
</template>
