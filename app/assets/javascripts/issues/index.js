import $ from 'jquery';
import IssuableForm from 'ee_else_ce/issuable/issuable_form';
import ShortcutsIssuable from '~/behaviors/shortcuts/shortcuts_issuable';
import ShortcutsNavigation from '~/behaviors/shortcuts/shortcuts_navigation';
import GLForm from '~/gl_form';
import { initIssuableHeaderWarnings, initIssuableSidebar } from '~/issuable';
import IssuableTemplateSelectors from '~/issuable/issuable_template_selectors';
import { IssueType } from '~/issues/constants';
import Issue from '~/issues/issue';
import { initTitleSuggestions, initTypePopover } from '~/issues/new';
import { initRelatedMergeRequests } from '~/issues/related_merge_requests';
import { initRelatedIssues } from '~/related_issues';
import {
  initHeaderActions,
  initIncidentApp,
  initIssueApp,
  initSentryErrorStackTrace,
} from '~/issues/show';
import { parseIssuableData } from '~/issues/show/utils/parse_data';
import LabelsSelect from '~/labels/labels_select';
import MilestoneSelect from '~/milestones/milestone_select';
import initNotesApp from '~/notes';
import { store } from '~/notes/stores';
import ZenMode from '~/zen_mode';
import initAwardsApp from '~/emoji/awards_app';
import initLinkedResources from '~/linked_resources';
import FilteredSearchServiceDesk from './filtered_search_service_desk';

export function initFilteredSearchServiceDesk() {
  if (document.querySelector('.filtered-search')) {
    const supportBotData = JSON.parse(
      document.querySelector('.js-service-desk-issues').dataset.supportBot,
    );
    const filteredSearchManager = new FilteredSearchServiceDesk(supportBotData);
    filteredSearchManager.setup();
  }
}

function initIssueCommandPalette() {
  if (!window.paletteCallbacks) window.paletteCallbacks = [];
  window.paletteCallbacks.push({
    id: 'project-items',
    callback: (items) => {
      items.unshift({
        id: 'issue-label-add',
        section: 'Issue',
        text: 'Add Label ...',
        icon: 'label',
        action: () => {
          alert('List of all Labels to select');
        },
      });

      items.unshift({
        id: 'issue-label-remove',
        section: 'Issue',
        text: 'Remove Label ...',
        icon: 'label',
        action: () => {
          alert('List of all current Labels to remove one');
        },
      });

      items.unshift({
        id: 'issue-assign-me',
        section: 'Issue',
        text: 'Assign to me',
        icon: 'assignee',
        action: () => {
          alert('Automatic assign to me / if assigned, possibility to unassign');
        },
      });
    },
  });
}

export function initForm() {
  new GLForm($('.issue-form')); // eslint-disable-line no-new
  new IssuableForm($('.issue-form')); // eslint-disable-line no-new
  new IssuableTemplateSelectors({ warnTemplateOverride: true }); // eslint-disable-line no-new
  new LabelsSelect(); // eslint-disable-line no-new
  new MilestoneSelect(); // eslint-disable-line no-new
  new ShortcutsNavigation(); // eslint-disable-line no-new

  initTitleSuggestions();
  initTypePopover();
}

export function initShow() {
  const el = document.getElementById('js-issuable-app');

  if (!el) {
    return;
  }

  const { issueType, ...issuableData } = parseIssuableData(el);

  if (issueType === IssueType.Incident) {
    initIncidentApp({ ...issuableData, issuableId: el.dataset.issuableId });
    initHeaderActions(store, IssueType.Incident);
    initLinkedResources();
    initRelatedIssues(IssueType.Incident);
  } else {
    initIssueApp(issuableData, store);
    initHeaderActions(store);
  }

  new Issue(); // eslint-disable-line no-new
  new ShortcutsIssuable(); // eslint-disable-line no-new
  new ZenMode(); // eslint-disable-line no-new
  initIssuableHeaderWarnings(store);
  initIssuableSidebar();
  initNotesApp();
  initRelatedMergeRequests();
  initSentryErrorStackTrace();

  initAwardsApp(document.getElementById('js-vue-awards-block'));

  initIssueCommandPalette();

  import(/* webpackChunkName: 'design_management' */ '~/design_management')
    .then((module) => module.default())
    .catch(() => {});
}
