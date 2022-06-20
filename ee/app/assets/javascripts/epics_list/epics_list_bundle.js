import Vue from 'vue';
import VueApollo from 'vue-apollo';

import { IssuableStates } from '~/vue_shared/issuable/list/constants';
import createDefaultClient from '~/lib/graphql';
import { parseBoolean, convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { queryToObject } from '~/lib/utils/url_utility';

import EpicsListApp from './components/epics_list_root.vue';

Vue.use(VueApollo);

export default function initEpicsList({ mountPointSelector }) {
  const mountPointEl = document.querySelector(mountPointSelector);

  if (!mountPointEl) {
    return null;
  }

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
  });

  const {
    page = 1,
    prev = '',
    next = '',
    initialState = IssuableStates.Opened,
    initialSortBy = 'start_date_desc',
    canCreateEpic,
    canBulkEditEpics,
    hasScopedLabelsFeature,
    epicsCountOpened,
    epicsCountClosed,
    epicsCountAll,
    epicNewPath,
    listEpicsPath,
    groupFullPath,
    labelsManagePath,
    labelsFetchPath,
    groupMilestonesPath,
    emptyStatePath,
    isSignedIn,
  } = mountPointEl.dataset;

  const rawFilterParams = queryToObject(window.location.search, { gatherArrays: true });
  const initialFilterParams = {
    ...convertObjectPropsToCamelCase(rawFilterParams, {
      dropKeys: ['scope', 'utf8', 'state', 'sort'], // These keys are unsupported/unnecessary
    }),
    // We shall put parsed value of `confidential` only
    // when it is defined.
    ...(rawFilterParams.confidential && {
      confidential: parseBoolean(rawFilterParams.confidential),
    }),
  };

  return new Vue({
    el: mountPointEl,
    name: 'EpicsListRoot',
    apolloProvider,
    provide: {
      initialState,
      initialSortBy,
      prev,
      next,
      page: parseInt(page, 10),
      canCreateEpic: parseBoolean(canCreateEpic),
      canBulkEditEpics: parseBoolean(canBulkEditEpics),
      hasScopedLabelsFeature: parseBoolean(hasScopedLabelsFeature),
      epicsCount: {
        [IssuableStates.Opened]: parseInt(epicsCountOpened, 10),
        [IssuableStates.Closed]: parseInt(epicsCountClosed, 10),
        [IssuableStates.All]: parseInt(epicsCountAll, 10),
      },
      labelsFetchPath: `${labelsFetchPath}?only_group_labels=true`,
      epicNewPath,
      listEpicsPath,
      groupFullPath,
      labelsManagePath,
      groupMilestonesPath,
      emptyStatePath,
      isSignedIn: parseBoolean(isSignedIn),
    },
    render: (createElement) =>
      createElement(EpicsListApp, {
        props: {
          initialFilterParams,
        },
      }),
  });
}
