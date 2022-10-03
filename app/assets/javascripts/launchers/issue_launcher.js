import { initShow } from '~/issues';
import { store } from '~/notes/stores';
import { initRelatedIssues } from '~/related_issues';
import initSidebarBundle from '~/sidebar/sidebar_bundle';

initShow();

import { addProjectBody } from './launcher_utils';

import IssueApp from './issue_app.vue';

export function initIssueLauncher() {
  document.addEventListener('showIssue', (e) => {
    console.log('Show Issue : ', e);
    addProjectBody('flightjs/Flight', IssueApp, {
      props: {
        projectId: 'flightjs/Flight',
        issue: e.detail,
      },
    });

    // Now lets reuse the classic Issue Init
    initShow(e.detail);

    initSidebarBundle(store);
    initRelatedIssues();
  });
}

export default initIssueLauncher;
