<script>
import { GlModal } from '@gitlab/ui';
import { s__ } from '~/locale';
import { SIDEBAR_VIEW_MODE, REFERRAL_EVENT } from 'ee/on_demand_scans/constants';

export default {
  i18n: {
    discardChangesHeader: s__('OnDemandScans|You have unsaved changes'),
    discardChangesText: s__(
      'OnDemandScans|Do you want to discard the changes or keep editing this profile? Unsaved changes will be lost.',
    ),
  },
  modal: {
    actionPrimary: {
      text: s__('OnDemandScans|Discard changes'),
      attributes: { variant: 'danger', 'data-testid': 'form-touched-warning' },
    },
    actionCancel: {
      text: s__('OnDemandScans|Keep editing'),
    },
  },
  name: 'DastProfilesConfiguratorModal',
  components: {
    GlModal,
  },
  data() {
    return {
      showDiscardChangesModal: false,
      cachedPayload: undefined,
      cashedReferralEvent: REFERRAL_EVENT.OPEN,
      formTouched: false,
    };
  },
  methods: {
    showModalOrBubbleEventUp(payload, eventName) {
      if (this.formTouched) {
        this.showDiscardChangesModal = true;
        this.cachedPayload = payload;
        this.cashedReferralEvent = eventName;
      } else {
        this.showDiscardChangesModal = false;
        this.$emit(eventName, payload);
      }
    },
    resetModalData() {
      this.formTouched = false;
      this.showDiscardChangesModal = false;
    },
    closeProfileDrawerProxy(event) {
      this.showModalOrBubbleEventUp(event, REFERRAL_EVENT.CLOSE);
    },
    onFormTouchedProxy(formTouched) {
      this.formTouched = formTouched;
    },
    enableEditingModeProxy(profileType) {
      const event = {
        mode: SIDEBAR_VIEW_MODE.EDITING_MODE,
        profileType,
      };

      this.showModalOrBubbleEventUp(event, REFERRAL_EVENT.EDIT);
    },
    openProfileDrawerProxy(event) {
      this.showModalOrBubbleEventUp(event, REFERRAL_EVENT.OPEN);
    },
    profileSubmittedProxy(event) {
      this.resetModalData();

      this.$emit(REFERRAL_EVENT.SUBMIT, event);
    },
    keepEditing() {
      this.showDiscardChangesModal = false;
    },
    discardChanges() {
      this.resetModalData();
      this.$emit(this.cashedReferralEvent, this.cachedPayload);

      this.cashedReferralEvent = REFERRAL_EVENT.OPEN;
      this.cachedPayload = undefined;
    },
  },
};
</script>

<template>
  <div>
    <gl-modal
      size="sm"
      modal-id="discard-changes-modal"
      data-testid="discard-changes-modal"
      :visible="showDiscardChangesModal"
      :title="$options.i18n.discardChangesHeader"
      :action-primary="$options.modal.actionPrimary"
      :action-cancel="$options.modal.actionCancel"
      @change="keepEditing"
      @canceled="keepEditing"
      @primary="discardChanges"
    >
      {{ $options.i18n.discardChangesText }}
    </gl-modal>
    <slot
      :enable-editing-mode-proxy="enableEditingModeProxy"
      :on-form-touched-proxy="onFormTouchedProxy"
      :close-profile-drawer-proxy="closeProfileDrawerProxy"
      :open-profile-drawer-proxy="openProfileDrawerProxy"
      :profile-submitted-proxy="profileSubmittedProxy"
    ></slot>
  </div>
</template>
