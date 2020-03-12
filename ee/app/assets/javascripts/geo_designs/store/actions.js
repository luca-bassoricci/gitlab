import Api from 'ee/api';
import createFlash from '~/flash';
import toast from '~/vue_shared/plugins/global_toast';
import { __ } from '~/locale';
import {
  parseIntPagination,
  normalizeHeaders,
  convertObjectPropsToCamelCase,
} from '~/lib/utils/common_utils';
import * as types from './mutation_types';
import { FILTER_STATES } from './constants';

// Fetch Replicable Items
export const requestReplicableItems = ({ commit }) => commit(types.REQUEST_REPLICABLE_ITEMS);
export const receiveReplicableItemsSuccess = ({ commit }, data) =>
  commit(types.RECEIVE_REPLICABLE_ITEMS_SUCCESS, data);
export const receiveReplicableItemsError = ({ commit }) => {
  createFlash(__('There was an error fetching the designs'));
  commit(types.RECEIVE_REPLICABLE_ITEMS_ERROR);
};

export const fetchDesigns = ({ state, dispatch }) => {
  dispatch('requestReplicableItems');

  const statusFilterName = state.filterOptions[state.currentFilterIndex]
    ? state.filterOptions[state.currentFilterIndex]
    : state.filterOptions[0];
  const query = {
    page: state.currentPage,
    search: state.searchFilter ? state.searchFilter : null,
    sync_status: statusFilterName === FILTER_STATES.ALL ? null : statusFilterName,
  };

  Api.getGeoDesigns(query)
    .then(res => {
      const normalizedHeaders = normalizeHeaders(res.headers);
      const paginationInformation = parseIntPagination(normalizedHeaders);
      const camelCaseData = convertObjectPropsToCamelCase(res.data, { deep: true });

      dispatch('receiveReplicableItemsSuccess', {
        data: camelCaseData,
        perPage: paginationInformation.perPage,
        total: paginationInformation.total,
      });
    })
    .catch(() => {
      dispatch('receiveReplicableItemsError');
    });
};

// Initiate All Replicable Syncs
export const requestInitiateAllReplicableSyncs = ({ commit }) =>
  commit(types.REQUEST_INITIATE_ALL_REPLICABLE_SYNCS);
export const receiveInitiateAllReplicableSyncsSuccess = ({ commit, dispatch }, { action }) => {
  toast(__(`All designs are being scheduled for ${action}`));
  commit(types.RECEIVE_INITIATE_ALL_REPLICABLE_SYNCS_SUCCESS);
  dispatch('fetchReplicableItems');
};
export const receiveInitiateAllReplicableSyncsError = ({ commit }) => {
  createFlash(__('There was an error syncing the designs.'));
  commit(types.RECEIVE_INITIATE_ALL_REPLICABLE_SYNCS_ERROR);
};

export const initiateAllDesignSyncs = ({ dispatch }, action) => {
  dispatch('requestInitiateAllReplicableSyncs');

  Api.initiateAllGeoDesignSyncs(action)
    .then(() => dispatch('receiveInitiateAllReplicableSyncsSuccess', { action }))
    .catch(() => {
      dispatch('receiveInitiateAllReplicableSyncsError');
    });
};

// Initiate Replicable Sync
export const requestInitiateReplicableSync = ({ commit }) =>
  commit(types.REQUEST_INITIATE_REPLICABLE_SYNC);
export const receiveInitiateReplicableSyncSuccess = ({ commit, dispatch }, { name, action }) => {
  toast(__(`${name} is scheduled for ${action}`));
  commit(types.RECEIVE_INITIATE_REPLICABLE_SYNC_SUCCESS);
  dispatch('fetchReplicableItems');
};
export const receiveInitiateReplicableSyncError = ({ commit }, { name }) => {
  createFlash(__(`There was an error syncing project '${name}'`));
  commit(types.RECEIVE_INITIATE_REPLICABLE_SYNC_ERROR);
};

export const initiateDesignSync = ({ dispatch }, { projectId, name, action }) => {
  dispatch('requestInitiateReplicableSync');

  Api.initiateGeoDesignSync({ projectId, action })
    .then(() => dispatch('receiveInitiateReplicableSyncSuccess', { name, action }))
    .catch(() => {
      dispatch('receiveInitiateReplicableSyncError', { name });
    });
};

// Filtering/Pagination
export const setFilter = ({ commit }, filterIndex) => {
  commit(types.SET_FILTER, filterIndex);
};

export const setSearch = ({ commit }, search) => {
  commit(types.SET_SEARCH, search);
};

export const setPage = ({ commit }, page) => {
  commit(types.SET_PAGE, page);
};
