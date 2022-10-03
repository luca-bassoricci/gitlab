<script>
import Vue from 'vue';
import { GlIcon } from '@gitlab/ui';
import CommandMenu from 'vue-cmd-menu';

import { db } from '../../lib/apollo/local_db';

export default Vue.extend({
  components: {
    CommandMenu,
    GlIcon,
  },
  data() {
    return {
      ownIssues: [],
      ownPages: [],
    };
  },
  computed: {
    actions() {
      const returnItems = [];

      const myLastPages = {
        id: 'my-pages',
        section: 'Your GitLab',
        text: 'My Last Pages',
        tag: 'My Last Pages',
        placeholder: 'Last Pages',
        icon: 'archive',
        childActions: [],
      };
      this.ownPages.forEach((page, ind) => {
        myLastPages.childActions.push({
          id: 'page-' + ind,
          text: page.title,
          action: () => {
            window.location.href = page.url;
          },
        });
      });
      returnItems.push(myLastPages);

      const myIssuesItem = {
        id: 'my-issues',
        section: 'Your GitLab',
        text: 'My Issues',
        tag: 'My Issues',
        placeholder: 'Issues',
        icon: 'issues',
        childActions: [
          {
            id: 'show-issues-assigned',
            text: 'All assigned issues',
            action: () => {
              alert('SHOW ISSUES ASSIGNED');
            },
          },
          {
            id: 'show-issues-author',
            text: 'All authored issues',
            action: () => {
              alert('SHOW ISSUES AUTHORED');
            },
          },
        ],
      };

      this.ownIssues.forEach((issue) => {
        myIssuesItem.childActions.push({
          id: 'issue-' + issue.id,
          text: issue.title,
          action: () => {
            // window.location.href = issue.webUrl;
            const event = new CustomEvent('showIssue', { detail: issue });
            document.dispatchEvent(event);
          },
        });
      });

      returnItems.push(myIssuesItem);

      const myMrItems = {
        id: 'my-mrs',
        section: 'Your GitLab',
        text: 'My Merge Requests',
        tag: 'My Merge Requests',
        placeholder: 'Merge Requests',
        icon: 'git-merge',
        childActions: [
          {
            id: 'mr-assigned-to-you',
            text: 'Assigned to me',
            action: () => {
              window.location.href = '/dashboard/merge_requests/?assignee_username=root';
            },
          },
          {
            id: 'mr-review-requests',
            text: 'Review requests for me',
            action: () => {
              window.location.href = '/dashboard/merge_requests?reviewer_username=root';
            },
          },
        ],
      };
      returnItems.push(myMrItems);

      const myProjects = {
        id: 'my-projects',
        section: 'Your GitLab',
        text: 'My Projects',
        tag: 'My Projects',
        icon: 'project',
        placeholder: 'My Projects',
        childActions: [],
      };
      returnItems.push(myProjects);

      const myGroups = {
        id: 'my-groups',
        section: 'Your GitLab',
        text: 'My Groups',
        tag: 'My Groups',
        icon: 'group',
        placeholder: 'My Groups',
        childActions: [],
      };
      returnItems.push(myGroups);

      if (window.paletteCallbacks) {
        window.paletteCallbacks.forEach((cbItem) => {
          if (cbItem.callback) cbItem.callback(returnItems);
        });
      }

      return returnItems;
    },
  },
  mounted() {
    console.log('Mounted Command Palette');

    db.issue.toArray().then((items) => {
      this.ownIssues = items;
    });

    db.pages
      .orderBy('timestamp')
      .toArray()
      .then((items) => {
        this.ownPages = items;
      });
  },
});
</script>

<template>
  <div id="app">
    <command-menu :actions="actions">
      <template v-slot:icon="{ icon }"> <gl-icon :name="icon" /> </template>
    </command-menu>
  </div>
</template>
