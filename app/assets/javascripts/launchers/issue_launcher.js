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
    addProjectBody(e.detail.project.fullPath, IssueApp, {
      props: {
        projectId: e.detail.project.fullPath,
        issue: e.detail,
      },
    });

    // Now lets reuse the classic Issue Init
    initShow(e.detail);

    initSidebarBundle(store);
    initRelatedIssues();

    window.history.pushState({}, '', e.detail.webPath);
  });
}

export default initIssueLauncher;
