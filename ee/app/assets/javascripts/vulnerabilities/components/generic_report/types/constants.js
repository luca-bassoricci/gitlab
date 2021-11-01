import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';

export const REPORT_TYPES = {
  base: 'VulnerabilityDetailBase',
  boolean: 'VulnerabilityDetailBoolean',
  int: 'VulnerabilityDetailInt',
  list: 'VulnerabilityDetailList',
  url: 'VulnerabilityDetailUrl',
  diff: 'VulnerabilityDetailDiff',
  // namedList: 'named-list', NODE: No-such GraphQL type yet
  text: 'VulnerabilityDetailText',
  value: 'VulnerabilityDetailBoolean',
  moduleLocation: 'VulnerabilityDetailModuleLocation',
  fileLocation: 'VulnerabilityDetailFileLocation',
  table: 'VulnerabilityDetailTable',
  code: 'VulnerabilityDetailCode',
  markdown: 'VulnerabilityDetailMarkdown',
  commit: 'VulnerabilityDetailCommit',
};

export const REPORT_COMPONENTS = {
  [REPORT_TYPES.base]: () => import('./value.vue'),
  [REPORT_TYPES.boolean]: () => import('./value.vue'),
  [REPORT_TYPES.int]: () => import('./value.vue'),
  [REPORT_TYPES.list]: () => import('./list.vue'),
  [REPORT_TYPES.url]: () => import('./url.vue'),
  [REPORT_TYPES.diff]: () => import('./diff.vue'),
  [REPORT_TYPES.namedList]: () => import('./named_list.vue'),
  [REPORT_TYPES.text]: () => import('./value.vue'),
  [REPORT_TYPES.value]: () => import('./value.vue'),
  [REPORT_TYPES.moduleLocation]: () => import('./module_location.vue'),
  [REPORT_TYPES.fileLocation]: () => import('./file_location.vue'),
  [REPORT_TYPES.table]: () => import('./table.vue'),
  [REPORT_TYPES.code]: () => import('./code.vue'),
  [REPORT_TYPES.markdown]: () => import('./markdown.vue'),
  [REPORT_TYPES.commit]: () => import('./commit.vue'),
};

// export const getComponentNameForType = (reportType) =>
//   `ReportType${capitalizeFirstCharacter(reportType)}`;

// export const REPORT_COMPONENTS = Object.fromEntries(
//   Object.entries(REPORT_TYPE_TO_COMPONENT_MAP).map(([reportType, component]) => [
//     getComponentNameForType(reportType),
//     component,
//   ]),
// );

/*
 * Diff component
 */
const DIFF = 'diff';
const BEFORE = 'before';
const AFTER = 'after';

export const VIEW_TYPES = { DIFF, BEFORE, AFTER };

const NORMAL = 'normal';
const REMOVED = 'removed';
const ADDED = 'added';

export const LINE_TYPES = { NORMAL, REMOVED, ADDED };
