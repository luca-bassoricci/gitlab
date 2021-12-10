<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: { GlButton },
  props: {
    cloudRunUrl: {
      type: String,
      required: true,
    },
    cloudStorageUrl: {
      type: String,
      required: true,
    },
  },
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
  <div class='gl-mx-3'>
    <h2 class='gl-font-size-h2'>{{ __('Deployments') }}</h2>
    <p>
      {{ __('Configure pipelines to deploy web apps, backend services, APIs and static resources to Google Cloud') }}
    </p>
    <table class='table b-table gl-table'>
      <thead>
      <tr>
        <th>
          <div>{{ __('Service') }}</div>
        </th>
        <th>
          <div>{{ __('Description') }}</div>
        </th>
        <th></th>
      </tr>
      </thead>
      <tbody>
      <tr>
        <td>
          {{ __('Cloud Run') }}
        </td>
        <td>
          {{ __('Deploy container based web apps on Google managed clusters') }}
        </td>
        <td>
          <gl-button
            category='primary'
            variant='info'
            :href='cloudRunUrl'
          >
            {{ __('Configure via Merge Request') }}
          </gl-button>
        </td>
      </tr>
      <tr>
        <td>
          {{ __('Cloud Storage') }}
        </td>
        <td>
          {{ __('Deploy static assets and resources to Google managed CDN') }}
        </td>
        <td>
          <gl-button
            category='primary'
            variant='info'
            :href='cloudStorageUrl'
          >
            {{ __('Configure via Merge Request') }}
          </gl-button>
        </td>
      </tr>
      </tbody>
    </table>
  </div>
</template>
