<script>
import { GlModal } from '@gitlab/ui';
import { __ } from '~/locale';
import {
  activateLabel,
  activateSubscription,
  subscriptionActivationInsertCode,
} from '../constants';
import SubscriptionActivationErrors from './subscription_activation_errors.vue';
import SubscriptionActivationForm from './subscription_activation_form.vue';

export default {
  actionCancel: { text: __('Cancel') },
  actionPrimary: {
    text: activateLabel,
  },
  bodyText: subscriptionActivationInsertCode,
  title: activateSubscription,
  name: 'SubscriptionActivationModal',
  components: {
    GlModal,
    SubscriptionActivationErrors,
    SubscriptionActivationForm,
  },
  props: {
    modalId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      error: null,
    };
  },
  methods: {
    handleActivationFailure(error) {
      this.error = error;
    },
    handleActivationSuccess() {
      this.$refs.modal.hide();
    },
    handlePrimary() {
      this.$refs.form.submit();
    },
    removeError() {
      this.error = null;
    },
  },
};
</script>

<template>
  <gl-modal
    ref="modal"
    :modal-id="modalId"
    :title="$options.title"
    :action-cancel="$options.actionCancel"
    :action-primary="$options.actionPrimary"
    @primary.prevent="handlePrimary"
    @hidden="removeError"
  >
    <subscription-activation-errors v-if="error" class="mb-4" :error="error" />
    <p>{{ $options.bodyText }}</p>
    <subscription-activation-form
      ref="form"
      :hide-submit-button="true"
      @subscription-activation-failure="handleActivationFailure"
      @subscription-activation-success="handleActivationSuccess"
    />
  </gl-modal>
</template>
