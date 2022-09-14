import Vue from 'vue';
import apolloProvider from 'ee/subscriptions/buy_addons_shared/graphql';
import { parseBoolean } from '~/lib/utils/common_utils';

import IdentityVerificationWizard from './components/wizard.vue';

export const initIdentityVerification = () => {
  const el = document.getElementById('js-identity-verification');

  if (!el) {
    return false;
  }

  const { creditCardFormId, creditCardCompleted } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    name: 'IdentityVerificationRoot',
    provide: {
      creditCardFormId,
      creditCardCompleted: parseBoolean(creditCardCompleted),
    },
    render(createElement) {
      return createElement(IdentityVerificationWizard);
    },
  });
};
