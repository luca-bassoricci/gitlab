<script>
import { GlAvatar, GlDropdown, GlDropdownItem, GlSearchBoxByType } from '@gitlab/ui';
import { debounce } from 'lodash';
import Api from 'ee/api';
import { sanitize } from '~/lib/dompurify';
import { __ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { AVATAR_SHAPE_OPTION_CIRCLE } from '~/vue_shared/constants';
import { NAMESPACE_TYPES } from 'ee/security_orchestration/constants';
import { TYPE_USER, TYPE_GROUP } from '../constants';

function addType(type) {
  return (items) => items.map((obj) => Object.assign(obj, { type }));
}

export default {
  components: {
    GlAvatar,
    GlDropdown,
    GlDropdownItem,
    GlSearchBoxByType,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    value: {
      type: Array,
      required: false,
      default: () => [],
    },
    namespaceId: {
      type: String,
      required: true,
    },
    skipUserIds: {
      type: Array,
      required: false,
      default: () => [],
    },
    skipGroupIds: {
      type: Array,
      required: false,
      default: () => [],
    },
    isInvalid: {
      type: Boolean,
      required: false,
      default: false,
    },
    namespaceType: {
      type: String,
      required: false,
      default: NAMESPACE_TYPES.PROJECT,
    },
  },
  data() {
    return {
      initialLoading: false,
      results: [],
      searchTerm: '',
      searching: false,
      selected: {},
    };
  },
  computed: {
    isFeatureEnabled() {
      return this.glFeatures.permitAllSharedGroupsForApproval;
    },
  },
  mounted() {
    this.initialLoading = true;
    this.fetchGroupsAndUsers('')
      .catch(() => {})
      .finally(() => {
        this.initialLoading = false;
      });
  },
  methods: {
    search: debounce(function debouncedSearch() {
      this.searching = true;
      this.fetchGroupsAndUsers(this.searchTerm)
        .catch(() => {})
        .finally(() => {
          this.searching = false;
        });
    }, 500),
    fetchGroupsAndUsers(term) {
      const groupsAsync = this.fetchGroups(term).then(addType(TYPE_GROUP));

      const usersAsync =
        this.namespaceType === NAMESPACE_TYPES.PROJECT
          ? this.fetchProjectUsers(term).then(addType(TYPE_USER))
          : this.fetchGroupUsers(term).then(({ data }) => addType(TYPE_USER)(data));

      return Promise.all([groupsAsync, usersAsync])
        .then(([groups, users]) => groups.concat(users))
        .then((results) => {
          this.results = results;
        });
    },
    fetchGroups(term) {
      if (this.isFeatureEnabled) {
        const hasTerm = term.trim().length > 0;
        const DEVELOPER_ACCESS_LEVEL = 30;

        return Api.projectGroups(this.namespaceId, {
          skip_groups: this.skipGroupIds,
          ...(hasTerm ? { search: term } : {}),
          with_shared: true,
          shared_visible_only: !this.isFeatureEnabled,
          shared_min_access_level: DEVELOPER_ACCESS_LEVEL,
        });
      }

      // Don't includeAll when search is empty. Otherwise, the user could get a lot of garbage choices.
      // https://gitlab.com/gitlab-org/gitlab/issues/11566
      const includeAll = term.trim().length > 0;

      return Api.groups(term, {
        skip_groups: this.skipGroupIds,
        all_available: includeAll,
      });
    },
    fetchProjectUsers(term) {
      return Api.projectUsers(this.namespaceId, term, {
        skip_users: this.skipUserIds,
      });
    },
    fetchGroupUsers(term) {
      return Api.groupMembers(this.namespaceId, {
        query: term,
        skip_users: this.skipUserIds,
      });
    },
    onSelect(value) {
      this.results = this.results.filter((el) => !(el.type === value.type) || el.id !== value.id);

      this.searchTerm = '';

      this.$emit('input', [value]);
    },
    sanitize,
  },
  i18n: {
    header: __('Search users or groups'),
  },
  TYPE_USER,
  AVATAR_SHAPE_OPTION_CIRCLE,
};
</script>

<template>
  <gl-dropdown
    :class="{ 'is-invalid': isInvalid }"
    class="gl-w-full gl-dropdown-menu-full-width"
    :header-text="$options.i18n.header"
    :loading="initialLoading"
  >
    <template #header>
      <gl-search-box-by-type v-model="searchTerm" :is-loading="searching" @input="search" />
    </template>
    <gl-dropdown-item
      v-for="result in results"
      :key="`${result.type}.${result.id}`"
      @click="onSelect(result)"
    >
      <div v-if="result.type === $options.TYPE_USER" class="user-result">
        <div class="user-image">
          <gl-avatar
            :shape="$options.AVATAR_SHAPE_OPTION_CIRCLE"
            :entity-id="result.id"
            :entity-name="result.name"
            :src="result.avatar_url"
            :alt="result.name"
            :size="32"
          />
        </div>
        <div class="user-info">
          <div class="user-name">{{ sanitize(result.name) }}</div>
          <div class="user-username">{{ sanitize(result.username) }}</div>
        </div>
      </div>
      <template v-else>
        <div class="user-result group-result">
          <div class="group-image">
            <gl-avatar
              :shape="$options.AVATAR_SHAPE_OPTION_CIRCLE"
              :entity-id="result.id"
              :entity-name="result.name"
              :src="result.avatar_url"
              :alt="result.name"
              :size="32"
            />
          </div>
          <div class="group-info">
            <div class="group-name">{{ sanitize(result.full_name) }}</div>
            <div class="group-path">{{ sanitize(result.full_path) }}</div>
          </div>
        </div>
      </template>
    </gl-dropdown-item>
  </gl-dropdown>
</template>
