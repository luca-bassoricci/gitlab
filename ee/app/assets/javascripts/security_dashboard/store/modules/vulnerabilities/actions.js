import $ from 'jquery';
import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';
import { parseIntPagination, normalizeHeaders } from '~/lib/utils/common_utils';
import { s__ } from '~/locale';
import createFlash from '~/flash';

export const setVulnerabilitiesEndpoint = ({ commit }, endpoint) => {
  commit(types.SET_VULNERABILITIES_ENDPOINT, endpoint);
};

export const setVulnerabilitiesCountEndpoint = ({ commit }, endpoint) => {
  commit(types.SET_VULNERABILITIES_COUNT_ENDPOINT, endpoint);
};

export const fetchVulnerabilitiesCount = ({ state, dispatch }) => {
  dispatch('requestVulnerabilitiesCount');

  axios({
    method: 'GET',
    url: state.vulnerabilitiesCountEndpoint,
  })
    .then(response => {
      const { data } = response;
      dispatch('receiveVulnerabilitiesCountSuccess', { data });
    })
    .catch(() => {
      dispatch('receiveVulnerabilitiesCountError');
    });
};

export const requestVulnerabilitiesCount = ({ commit }) => {
  commit(types.REQUEST_VULNERABILITIES_COUNT);
};

export const receiveVulnerabilitiesCountSuccess = ({ commit }, { data }) => {
  commit(types.RECEIVE_VULNERABILITIES_COUNT_SUCCESS, data);
};

export const receiveVulnerabilitiesCountError = ({ commit }) => {
  commit(types.RECEIVE_VULNERABILITIES_COUNT_ERROR);
};

export const fetchVulnerabilities = ({ state, dispatch }, pageNumber) => {
  dispatch('requestVulnerabilities');

  const page = pageNumber || (state.pageInfo && state.pageInfo.page) || 1;

  axios({
    method: 'GET',
    url: state.vulnerabilitiesEndpoint,
    params: { page },
  })
    .then(response => {
      const { headers, data } = response;
      dispatch('receiveVulnerabilitiesSuccess', { headers, data });
    })
    .catch(() => {
      dispatch('receiveVulnerabilitiesError');
    });
};

export const requestVulnerabilities = ({ commit }) => {
  commit(types.REQUEST_VULNERABILITIES);
};

export const receiveVulnerabilitiesSuccess = ({ commit }, { headers, data }) => {
  const normalizedHeaders = normalizeHeaders(headers);
  const pageInfo = parseIntPagination(normalizedHeaders);
  const vulnerabilities = data;

  commit(types.RECEIVE_VULNERABILITIES_SUCCESS, { pageInfo, vulnerabilities });
};

export const receiveVulnerabilitiesError = ({ commit }) => {
  commit(types.RECEIVE_VULNERABILITIES_ERROR);
};

export const openModal = ({ commit }, payload = {}) => {
  $('#modal-mrwidget-security-issue').modal('show');

  commit(types.SET_MODAL_DATA, payload);
};

export const createIssue = ({ dispatch }, { vulnerability, flashError }) => {
  dispatch('requestCreateIssue');
  axios
    .post(vulnerability.vulnerability_feedback_url, {
      vulnerability_feedback: {
        feedback_type: 'issue',
        category: vulnerability.report_type,
        project_fingerprint: vulnerability.project_fingerprint,
        vulnerability_data: {
          ...vulnerability,
          category: vulnerability.report_type,
        },
      },
    })
    .then(({ data }) => {
      dispatch('receiveCreateIssueSuccess', data);
    })
    .catch(() => {
      dispatch('receiveCreateIssueError', { flashError });
    });
};

export const requestCreateIssue = ({ commit }) => {
  commit(types.REQUEST_CREATE_ISSUE);
};

export const receiveCreateIssueSuccess = ({ commit }, payload) => {
  commit(types.RECEIVE_CREATE_ISSUE_SUCCESS, payload);
};

export const receiveCreateIssueError = ({ commit }) => {
  commit(types.RECEIVE_CREATE_ISSUE_ERROR);
  createFlash(s__('Security Reports|There was an error creating the issue.'));
};

export const dismissVulnerability = ({ dispatch }, { vulnerability, flashError }) => {
  dispatch('requestDismissVulnerability');

  axios
    .post(vulnerability.vulnerability_feedback_url, {
      vulnerability_feedback: {
        feedback_type: 'dismissal',
        category: vulnerability.report_type,
        project_fingerprint: vulnerability.project_fingerprint,
        vulnerability_data: {
          ...vulnerability,
          category: vulnerability.report_type,
        },
      },
    })
    .then(({ data }) => {
      const { id } = vulnerability;
      dispatch('receiveDismissVulnerabilitySuccess', { id, data });
    })
    .catch(() => {
      dispatch('receiveDismissVulnerabilityError', { flashError });
    });
};

export const requestDismissVulnerability = ({ commit }) => {
  commit(types.REQUEST_DISMISS_VULNERABILITY);
};

export const receiveDismissVulnerabilitySuccess = ({ commit }, payload) => {
  commit(types.RECEIVE_DISMISS_VULNERABILITY_SUCCESS, payload);
};

export const receiveDismissVulnerabilityError = ({ commit }, { flashError }) => {
  commit(types.RECEIVE_DISMISS_VULNERABILITY_ERROR);
  if (flashError) {
    createFlash(s__('Security Reports|There was an error dismissing the issue.'));
  }
};

export const undoDismissal = ({ dispatch }, { vulnerability, flashError }) => {
  const { vulnerability_feedback_url, dismissal_feedback } = vulnerability;
  // eslint-disable-next-line camelcase
  const url = `${vulnerability_feedback_url}/${dismissal_feedback.id}`;

  dispatch('requestUndoDismissal');

  axios
    .delete(url)
    .then(() => {
      const { id } = vulnerability;
      dispatch('receiveUndoDismissalSuccess', { id });
    })
    .catch(() => {
      dispatch('receiveUndoDismissalError', { flashError });
    });
};

export const requestUndoDismissal = ({ commit }) => {
  commit(types.REQUEST_UNDO_DISMISSAL);
};

export const receiveUndoDismissalSuccess = ({ commit }, payload) => {
  commit(types.RECEIVE_UNDO_DISMISSAL_SUCCESS, payload);
};

export const receiveUndoDismissalError = ({ commit }, { flashError }) => {
  commit(types.RECEIVE_UNDO_DISMISSAL_ERROR);
  if (flashError) {
    createFlash(s__('Security Reports|There was an error undoing this dismissal.'));
  }
};

export default () => {};
