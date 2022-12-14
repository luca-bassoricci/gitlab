<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import {
  manualSyncFailureText,
  connectivityIssue,
  manualSyncSuccessfulTitle,
  subscriptionSyncStatus,
} from '../constants';

export const SUCCESS_ALERT_DISMISSED_EVENT = 'success-alert-dismissed';

const subscriptionSyncStatusValidator = (value) =>
  !value || Object.values(subscriptionSyncStatus).includes(value);

export default {
  name: 'SubscriptionSyncNotifications',
  i18n: {
    manualSyncSuccessfulTitle,
    manualSyncFailureText,
    connectivityIssue,
  },
  components: {
    GlAlert,
    GlLink,
    GlSprintf,
  },
  inject: ['connectivityHelpURL'],
  props: {
    syncStatus: {
      type: String,
      required: true,
      validator: subscriptionSyncStatusValidator,
    },
  },
  computed: {
    syncDidSuccess() {
      return this.syncStatus === subscriptionSyncStatus.SYNC_SUCCESS;
    },
    syncDidFail() {
      return this.syncStatus === subscriptionSyncStatus.SYNC_FAILURE;
    },
  },
  methods: {
    didDismissSuccessAlert() {
      this.$emit(SUCCESS_ALERT_DISMISSED_EVENT);
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="syncDidSuccess"
      variant="success"
      :title="$options.i18n.manualSyncSuccessfulTitle"
      data-testid="sync-success-alert"
      @dismiss="didDismissSuccessAlert"
    />
    <gl-alert
      v-else-if="syncDidFail"
      variant="danger"
      :dismissible="false"
      :title="$options.i18n.connectivityIssue"
      data-testid="sync-failure-alert"
    >
      <gl-sprintf :message="$options.i18n.manualSyncFailureText">
        <template #connectivityHelpLink="{ content }">
          <gl-link :href="connectivityHelpURL" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>
  </div>
</template>
