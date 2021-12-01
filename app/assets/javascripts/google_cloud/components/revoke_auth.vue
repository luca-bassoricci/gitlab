<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: { GlButton },
  data() {
    return {
      tableFields: [
        { label: __('Service'), sortable: true },
        { label: __('Description'), sortable: true },
        { label: __(' '), sortable: true },
      ],
    };
  },
};
</script>
<template>
  <div class="gl-mx-3">
    <h2 class="gl-font-size-h2">{{ __('Revoke authorizations') }}</h2>
    <p>{{ __('Revoke authorizations granted to GitLab') }}</p>
    <gl-button category="secondary" variant="danger" href="./google_cloud/revoke">{{
      __('Revoke authorizations')
    }}</gl-button>
  </div>
</template>
