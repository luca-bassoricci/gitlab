export const groupData = [
  { id: '1', full_name: 'Foo' },
  { id: '2', full_name: 'Bar' },
];

export const groupNodes = [
  {
    __typename: 'Group',
    full_name: 'Foo',
    id: '1',
  },
  {
    __typename: 'Group',
    full_name: 'Bar',
    id: '2',
  },
];

export const groupNodeLabelValues = [
  { label: 'Foo', value: '1' },
  { label: 'Bar', value: '2' },
];

export const groupIds = [1, 2];

export const groupGids = ['gid://gitlab/Group/1', 'gid://gitlab/Group/2'];

export const groupPageInfo = {
  nextPage: 2,
};

export const devopsAdoptionNamespaceData = {
  nodes: [
    {
      id: 1,
      namespace: {
        fullName: 'Group 1',
        id: 'gid://gitlab/Group/1',
      },
      latestSnapshot: {
        issueOpened: true,
        mergeRequestOpened: true,
        mergeRequestApproved: false,
        runnerConfigured: true,
        pipelineSucceeded: false,
        deploySucceeded: false,
        securityScanSucceeded: false,
        codeOwnersUsedCount: 0,
        recordedAt: '2020-10-31T23:59:59Z',
        __typename: 'latestSnapshot',
      },
      __typename: 'devopsAdoptionEnabledNamespace',
    },
    {
      id: 2,
      namespace: {
        fullName: 'Group 2',
        id: 'gid://gitlab/Group/2',
      },
      latestSnapshot: null,
      __typename: 'devopsAdoptionEnabledNamespace',
    },
  ],
  __typename: 'devopsAdoptionEnabledNamespaces',
};

export const devopsAdoptionNamespaceDataEmpty = {
  nodes: [],
  __typename: 'devopsAdoptionSegments',
};

export const devopsAdoptionTableHeaders = [
  {
    index: 0,
    label: 'Group',
    tooltip: null,
  },
  {
    index: 1,
    label: 'Issues',
    tooltip: 'At least one issue opened',
  },
  {
    index: 2,
    label: 'MRs',
    tooltip: 'At least one MR opened',
  },
  {
    index: 3,
    label: 'Approvals',
    tooltip: 'At least one approval on an MR',
  },
  {
    index: 4,
    label: 'Code owners',
    tooltip: 'Code owners enabled for at least one project',
  },
  {
    index: 5,
    label: '',
    tooltip: null,
  },
];

export const segmentName = 'Foooo';

export const genericErrorMessage = 'An error occurred while saving changes. Please try again.';

export const dataErrorMessage = 'Name already taken.';

export const genericDeleteErrorMessage =
  'An error occurred while removing the group. Please try again.';
