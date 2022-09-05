<script>
import { debounce, uniqBy } from 'lodash';
import { GlDropdownDivider, GlTooltipDirective, GlListbox } from '@gitlab/ui';
import { __ } from '~/locale';
import SidebarParticipant from '~/sidebar/components/assignees/sidebar_participant.vue';
import { IssuableType } from '~/issues/constants';
import { DEFAULT_DEBOUNCE_AND_THROTTLE_MS } from '~/lib/utils/constants';
import { participantsQueries, userSearchQueries } from '~/sidebar/constants';
import { convertToGraphQLId } from '~/graphql_shared/utils';

export default {
  i18n: {
    unassigned: __('Unassigned'),
    assignees: __('Assignees'),
  },
  components: {
    GlDropdownDivider,
    SidebarParticipant,
    GlListbox,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    headerText: {
      type: String,
      required: true,
    },
    text: {
      type: String,
      required: true,
    },
    fullPath: {
      type: String,
      required: true,
    },
    iid: {
      type: String,
      required: true,
    },
    value: {
      type: Array,
      required: true,
    },
    allowMultipleAssignees: {
      type: Boolean,
      required: false,
      default: false,
    },
    currentUser: {
      type: Object,
      required: true,
    },
    issuableType: {
      type: String,
      required: false,
      default: IssuableType.Issue,
    },
    isEditing: {
      type: Boolean,
      required: false,
      default: true,
    },
    issuableId: {
      type: Number,
      required: false,
      default: null,
    },
    issuableAuthor: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      search: '',
      participants: [],
      searchUsers: [],
      isSearching: false,
      selected: this.allowMultipleAssignees
        ? this.value.map(({ username }) => username)
        : this.value[0],
    };
  },
  apollo: {
    participants: {
      query() {
        return participantsQueries[this.issuableType].query;
      },
      skip() {
        return Boolean(participantsQueries[this.issuableType].skipQuery) || !this.isEditing;
      },
      variables() {
        return {
          iid: this.iid,
          fullPath: this.fullPath,
        };
      },
      update(data) {
        return data.workspace?.issuable?.participants.nodes.map((node) => ({
          ...node,
          value: node.username,
          canMerge: false,
        }));
      },
      error() {
        this.$emit('error');
      },
    },
    searchUsers: {
      query() {
        return userSearchQueries[this.issuableType].query;
      },
      variables() {
        return this.searchUsersVariables;
      },
      skip() {
        return !this.isEditing;
      },
      update(data) {
        return (
          data.workspace?.users?.nodes
            .filter((x) => x?.user)
            .map((node) => ({
              ...node.user,
              canMerge: node.mergeRequestInteraction?.canMerge || false,
            })) || []
        );
      },
      error() {
        this.$emit('error');
        this.isSearching = false;
      },
      result() {
        this.isSearching = false;
      },
    },
  },
  computed: {
    isMergeRequest() {
      return this.issuableType === IssuableType.MergeRequest;
    },
    searchUsersVariables() {
      const variables = {
        fullPath: this.fullPath,
        search: this.search,
        first: 20,
      };
      if (!this.isMergeRequest) {
        return variables;
      }
      return {
        ...variables,
        mergeRequestId: convertToGraphQLId('MergeRequest', this.issuableId),
      };
    },
    isLoading() {
      return this.$apollo.queries.searchUsers.loading || this.$apollo.queries.participants.loading;
    },
    users() {
      if (!this.participants) {
        return [];
      }

      const filteredParticipants = this.participants.filter(
        (user) => user.name.includes(this.search) || user.username.includes(this.search),
      );

      // TODO this de-duplication is temporary (BE fix required)
      // https://gitlab.com/gitlab-org/gitlab/-/issues/327822
      const mergedSearchResults = this.searchUsers
        .concat(filteredParticipants)
        .reduce(
          (acc, current) => (acc.some((user) => current.id === user.id) ? acc : [...acc, current]),
          [],
        );

      return this.moveCurrentUserAndAuthorToStart(mergedSearchResults);
    },
    isSearchEmpty() {
      return this.search === '';
    },
    shouldShowParticipants() {
      return this.isSearchEmpty || this.isSearching;
    },
    isCurrentUserInList() {
      const isCurrentUser = (user) => user.username === this.currentUser.username;
      return this.users.some(isCurrentUser);
    },
    showCurrentUser() {
      return this.currentUser.username && !this.isCurrentUserInList && this.isSearchEmpty;
    },
    showAuthor() {
      return (
        this.issuableAuthor &&
        !this.users.some((user) => user.id === this.issuableAuthor.id) &&
        this.isSearchEmpty
      );
    },
    selectedFiltered() {
      if (this.shouldShowParticipants) {
        return this.moveCurrentUserAndAuthorToStart(this.value);
      }

      const foundUsernames = this.users.map(({ username }) => username);
      const filtered = this.value.filter(({ username }) => foundUsernames.includes(username));
      return this.moveCurrentUserAndAuthorToStart(filtered);
    },
    selectedUserNames() {
      return this.value.map(({ username }) => username);
    },
    unselectedFiltered() {
      return this.users?.filter(({ username }) => !this.selectedUserNames.includes(username)) || [];
    },
    displayUsers() {
      const users = [...this.selectedFiltered];

      if (this.showCurrentUser) {
        users.push(this.currentUser);
      }

      if (this.showAuthor) {
        users.push(this.issuableAuthor);
      }

      return users.concat(this.unselectedFiltered);
    },
  },

  watch: {
    // We need to add this watcher to track the moment when user is already typing
    // but query is still not started due to debounce
    search(newVal) {
      if (newVal) {
        this.isSearching = true;
      }
    },
  },
  created() {
    this.debouncedSearchKeyUpdate = debounce(this.setSearchKey, DEFAULT_DEBOUNCE_AND_THROTTLE_MS);
  },

  methods: {
    select() {
      if (this.allowMultipleAssignees) {
        const newSelected = this.users.filter(({ username }) => this.selected.includes(username));
        const selectedUsers = uniqBy([...this.value, ...newSelected], 'username');

        this.$emit('input', selectedUsers);
      } else {
        this.$emit('input', this.selected);
        this.$emit('toggle');
      }
    },
    unselect(name) {
      const selected = this.value.filter((user) => user.username !== name);
      this.$emit('input', selected);
    },
    showDropdown() {
      setTimeout(() => {
        this.$refs.listbox.open();
      }, 0);
    },
    moveCurrentUserAndAuthorToStart(users = []) {
      let sortedUsers = [...users];

      const author = sortedUsers.find((user) => user.id === this.issuableAuthor?.id);
      if (author) {
        sortedUsers = [author, ...sortedUsers.filter((user) => user.id !== author.id)];
      }

      const currentUser = sortedUsers.find((user) => user.username === this.currentUser.username);

      if (currentUser) {
        currentUser.canMerge = this.currentUser.canMerge;
        sortedUsers = [currentUser, ...sortedUsers.filter((user) => user.id !== currentUser.id)];
      }

      return sortedUsers;
    },
    setSearchKey(value) {
      this.search = value.trim();
    },
    tooltipText(user) {
      if (!this.isMergeRequest) {
        return '';
      }
      return user.canMerge ? '' : __('Cannot merge');
    },
  },
};
</script>

<template>
  <gl-listbox
    ref="listbox"
    v-model="selected"
    class="gl-display-block"
    :style="{ height: 400 }"
    :items="displayUsers"
    :toggle-text="$options.i18n.assignees"
    :multiple="allowMultipleAssignees"
    is-check-centered
    is-filterable
    :searching="isLoading"
    primary-key="username"
    @select="select"
    @unselect="unselect"
    @search="debouncedSearchKeyUpdate"
  >
    <template #header>
      <p class="gl-font-weight-bold gl-text-center gl-mt-2 gl-mb-4">{{ headerText }}</p>
      <gl-dropdown-divider />
    </template>

    <template #list-item="{ item }">
      <sidebar-participant :user="item" :issuable-type="issuableType" />
    </template>

    <template #footer>
      <gl-dropdown-divider />
      <slot name="footer"></slot>
    </template>
  </gl-listbox>
</template>
