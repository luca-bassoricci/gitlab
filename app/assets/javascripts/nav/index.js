import { mountIssuesListApp } from '~/issues/list';

// TODO: With the combined_menu feature flag removed, there's likely a better
// way to slice up the async import (i.e., include trigger in main bundle, but
// async import subviews. Don't do this at the cost of UX).
// See https://gitlab.com/gitlab-org/gitlab/-/issues/336042
const importModule = () => import(/* webpackChunkName: 'top_nav' */ './mount');

const tryMountTopNav = async () => {
  const el = document.getElementById('js-top-nav');

  if (!el) {
    return;
  }

  const { mountTopNav } = await importModule();

  mountTopNav(el);
};

const tryMountTopNavResponsive = async () => {
  const el = document.getElementById('js-top-nav-responsive');

  if (!el) {
    return;
  }

  const { mountTopNavResponsive } = await importModule();

  mountTopNavResponsive(el);
};

const prepareBody = () => {
  // Faking the injection of the DIV which would need to find some of the data dynamically
  const pageElement = document.querySelector('.layout-page');
  let newHTML = '';
  newHTML += '<div class="container-fluid container-limited ">';
  newHTML +=
    '<div class="page-title-holder d-flex align-items-center"><h1 class="page-title gl-font-size-h-display">Issues</h1><div class="page-title-controls"><div class="dropdown b-dropdown gl-new-dropdown btn-group project-item-select-holder gl-display-inline-flex!"><a class="btn gl-button btn-confirm split-content-button js-new-project-item-link block-truncated" data-label="issue" data-type="issues" href=""><span class="gl-spinner-container" role="status"><span class="gl-spinner gl-spinner-light gl-spinner-sm gl-vertical-align-text-bottom!" aria-label="Loading"></span></span></a><input type="hidden" name="project_path" id="project_path" class="project-item-select gl-absolute! gl-visibility-hidden ajax-project-select" data-order-by="last_activity_at" data-relative-path="issues/new" data-with-issues-enabled="true" autocomplete="off"><button aria-label="Toggle project select" class="btn dropdown-toggle btn-confirm btn-md gl-button gl-dropdown-toggle dropdown-toggle-split new-project-item-select-button"></button></div><!-- END app/views/shared/_new_project_item_select.html.haml --></div></div>';
  newHTML +=
    '<div class="js-issues-list" data-autocomplete-award-emojis-path="/-/autocomplete/award_emojis" data-calendar-path="/flightjs/Flight/-/issues.ics?due_date=next_month_and_previous_two_weeks&amp;feed_token=SL3i6vM8Y5dhpziXoRCn&amp;sort=closest_future_date" data-can-bulk-update="true" data-can-edit="true" data-can-import-issues="true" data-can-read-crm-contact="false" data-can-read-crm-organization="false" data-email="admin@example.com" data-emails-help-page-path="/help/development/emails#email-namespace" data-empty-state-svg-path="/assets/illustrations/issues-b4cb30d5143b86be2f594c7a384296dfba0b25199db87382c3746b79dafd6161.svg" data-export-csv-path="/flightjs/Flight/-/issues/export_csv" data-full-path="flightjs/Flight" data-has-any-issues="true" data-has-blocked-issues-feature="false" data-has-issuable-health-status-feature="false" data-has-issue-weights-feature="false" data-has-iterations-feature="false" data-has-multiple-issue-assignees-feature="false" data-has-scoped-labels-feature="false" data-import-csv-issues-path="/flightjs/Flight/-/issues/import_csv" data-initial-sort="created_date" data-is-anonymous-search-disabled="false" data-is-issue-repositioning-disabled="false" data-is-project="true" data-is-public-visibility-restricted="false" data-is-signed-in="true" data-jira-integration-path="http://localhost:3000/help/integration/jira/issues#view-jira-issues" data-markdown-help-path="/help/user/markdown" data-max-attachment-size="10 MB" data-new-issue-path="/flightjs/Flight/-/issues/new" data-project-import-jira-path="/flightjs/Flight/-/import/jira" data-quick-actions-help-path="/help/user/project/quick_actions" data-releases-path="/flightjs/Flight/-/releases.json" data-reset-path="/flightjs/Flight/new_issuable_address?issuable_type=issue" data-rss-path="/flightjs/Flight/-/issues.atom?feed_token=SL3i6vM8Y5dhpziXoRCn" data-show-new-issue-link="true" data-sign-in-path="/users/sign_in"></div>';
  newHTML += '</div>';
  pageElement.innerHTML = newHTML;
};

const linkIssuesButton = async () => {
  const el = document.querySelector('.dashboard-shortcuts-issues');
  el.setAttribute('href', '#');

  el.addEventListener('click', () => {
    prepareBody();
    mountIssuesListApp(true);
  });
};

export const initTopNav = async () =>
  Promise.all([tryMountTopNav(), tryMountTopNavResponsive(), linkIssuesButton()]);
