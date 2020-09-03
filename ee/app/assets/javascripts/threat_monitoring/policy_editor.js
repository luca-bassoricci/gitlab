import Vue from 'vue';
import PolicyEditorApp from './components/policy_editor/policy_editor.vue';
import createStore from './store';

export default () => {
  const el = document.querySelector('#js-policy-builder-app');
  const { environmentsEndpoint, networkPoliciesEndpoint, threatMonitoringPath } = el.dataset;

  const store = createStore();
  store.dispatch('threatMonitoring/setEndpoints', {
    environmentsEndpoint,
  });
  store.dispatch('networkPolicies/setEndpoints', {
    networkPoliciesEndpoint,
  });

  return new Vue({
    el,
    store,
    render(createElement) {
      return createElement(PolicyEditorApp, {
        props: { threatMonitoringPath },
      });
    },
  });
};
