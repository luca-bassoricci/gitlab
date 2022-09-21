import ShortcutsNavigation from '~/behaviors/shortcuts/shortcuts_navigation';
import findAndFollowLink from '~/lib/utils/navigation_utility';
import initTerraformNotification from '~/projects/terraform_notification';
import { initSidebarTracking } from '../shared/nav/sidebar_tracking';
import Project from './project';

new Project(); // eslint-disable-line no-new
new ShortcutsNavigation(); // eslint-disable-line no-new
initSidebarTracking();
initTerraformNotification();

console.log('Every Project Page --- here');
if (!window.paletteCallbacks) window.paletteCallbacks = [];
window.paletteCallbacks.push({
  id: 'project-items',
  callback: function (items) {
    const projectTitle = 'Project ' + document.querySelector('.sidebar-context-title').innerText;
    console.log('ADD PROJECT PALETTE ITEMS');
    items.push({
      id: 'project-overview',
      section: projectTitle,
      text: 'Overview',
      icon: 'project',
      action: () => findAndFollowLink('.shortcuts-project'),
    });
    items.push({
      id: 'project-activity',
      section: projectTitle,
      text: 'Activity',
      icon: 'project',
      action: () => findAndFollowLink('.shortcuts-project-activity'),
    });
    items.push({
      id: 'project-labels',
      section: projectTitle,
      text: 'Labels',
      icon: 'project',
      action: () => {
        alert('Labels page');
      },
    });
    items.push({
      id: 'project-members',
      section: projectTitle,
      text: 'Members',
      icon: 'project',
      action: () => {
        alert('Members');
      },
    });
    items.push({
      id: 'project-repository',
      section: projectTitle,
      text: 'Files',
      icon: 'doc-text',
      action: () => findAndFollowLink('.shortcuts-tree'),
    });
    items.push({
      id: 'project-commits',
      section: projectTitle,
      text: 'Commits',
      icon: 'doc-text',
      action: () => findAndFollowLink('.shortcuts-commits'),
    });
    items.push({
      id: 'project-issues-list',
      section: projectTitle,
      text: 'Issues List',
      icon: 'issues',
      action: () => findAndFollowLink('.shortcuts-issues'),
    });
    items.push({
      id: 'project-issues-new',
      section: projectTitle,
      text: 'New issue',
      icon: 'issue-new',
      action: () => findAndFollowLink('.shortcuts-new-issue'),
    });
    items.push({
      id: 'project-mrs',
      section: projectTitle,
      text: 'Merge request list',
      icon: 'git-merge',
      action: () => findAndFollowLink('.shortcuts-merge_requests'),
    });
  },
});
