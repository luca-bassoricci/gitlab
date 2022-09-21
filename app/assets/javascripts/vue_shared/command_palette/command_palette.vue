<script>
import Vue from 'vue';
import CommandMenu from 'vue-cmd-menu';

import { db } from '../../lib/apollo/local_db';

export default Vue.extend({
  components: {
    CommandMenu,
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
            window.location.href = issue.webUrl;
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
        placeholder: 'My Projects',
        childActions: [],
      };
      returnItems.push(myProjects);

      return returnItems;
    },
  },
  mounted() {
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
    <command-menu :actions="actions" />
  </div>
</template>
