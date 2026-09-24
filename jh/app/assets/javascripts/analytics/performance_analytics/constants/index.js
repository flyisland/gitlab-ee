import { __, s__ } from '~/locale';

export const DATE_RANGE_LIST = [7, 14, 30];
export const DEFAULT_SELECT_RANGE = 30;
export const DATE_RANGE_LIMIT = 180;

export const PERFORMANCE_TYPE_CLOSED_ISSUES = 'issuesClosed';
export const PERFORMANCE_TYPE_COMMITS_NUMBER = 'commitsPushed';
export const PERFORMANCE_TYPE_MERGED_REQUESTS = 'mergeRequestsMerged';
export const PERFORMANCE_TYPE_PER_CAPITA_COMMITS = 'commitsPushedPerCapita';

export const PERFORMANCE_TYPE_INDICATOR_TEXT = {
  [PERFORMANCE_TYPE_CLOSED_ISSUES]: s__('JH|PerformanceAnalytics|Closed issues'),
  [PERFORMANCE_TYPE_COMMITS_NUMBER]: __('Number of commits'),
  [PERFORMANCE_TYPE_MERGED_REQUESTS]: s__('JH|PerformanceAnalytics|Merged MRs'),
  [PERFORMANCE_TYPE_PER_CAPITA_COMMITS]: s__('JH|Average Commits Per User'),
};

export const PERFORMANCE_TYPE_PUSH_TEXTS = {
  [PERFORMANCE_TYPE_COMMITS_NUMBER]: s__('JH|PerformanceAnalytics|Number of pushes'),
  [PERFORMANCE_TYPE_PER_CAPITA_COMMITS]: s__('JH|PerformanceAnalytics|Average Pushes Per User'),
};

export const PUSH_COLUMNS_TEXT = __('Pushes');

export const PERFORMANCE_TYPE_INDICATOR_ICONS = {
  [PERFORMANCE_TYPE_CLOSED_ISSUES]: 'issues',
  [PERFORMANCE_TYPE_COMMITS_NUMBER]: 'commit',
  [PERFORMANCE_TYPE_MERGED_REQUESTS]: 'merge-request',
  [PERFORMANCE_TYPE_PER_CAPITA_COMMITS]: 'commit',
};

export const AVATAR_SIZE = 32;

export const RANK_DROPDOWN_OPTIONS = [
  {
    value: PERFORMANCE_TYPE_COMMITS_NUMBER,
    text: PERFORMANCE_TYPE_INDICATOR_TEXT[PERFORMANCE_TYPE_COMMITS_NUMBER],
  },
  {
    value: PERFORMANCE_TYPE_CLOSED_ISSUES,
    text: PERFORMANCE_TYPE_INDICATOR_TEXT[PERFORMANCE_TYPE_CLOSED_ISSUES],
  },
  {
    value: PERFORMANCE_TYPE_MERGED_REQUESTS,
    text: PERFORMANCE_TYPE_INDICATOR_TEXT[PERFORMANCE_TYPE_MERGED_REQUESTS],
  },
];

const defaultFieldOption = {
  thAttr: { 'data-testid': 'headers' },
};

export const PERFORMANCE_TABLE_FULLNAME = 'fullname';

export const PERFORMANCE_TABLE_COLUMNS = [
  {
    key: PERFORMANCE_TABLE_FULLNAME,
    label: s__('JH|PerformanceAnalytics|Name'),
    sortable: true,
    ...defaultFieldOption,
  },
  {
    key: 'commitsPushed',
    label: s__('JH|PerformanceAnalytics|Commits'),
    sortable: true,
    ...defaultFieldOption,
  },
  {
    key: 'issuesCreated',
    label: s__('JH|PerformanceAnalytics|Created issues'),
    sortable: true,
    ...defaultFieldOption,
  },
  {
    key: 'issuesClosed',
    label: s__('JH|PerformanceAnalytics|Closed issues'),
    sortable: true,
    ...defaultFieldOption,
  },
  {
    key: 'mergeRequestsCreated',
    label: s__('JH|PerformanceAnalytics|Created MRs'),
    sortable: true,
    ...defaultFieldOption,
  },
  {
    key: 'mergeRequestsApproved',
    label: s__('JH|PerformanceAnalytics|Approved MRs'),
    sortable: true,
    ...defaultFieldOption,
  },
  {
    key: 'mergeRequestsMerged',
    label: s__('JH|PerformanceAnalytics|Merged MRs'),
    sortable: true,
    ...defaultFieldOption,
  },
  {
    key: 'mergeRequestsClosed',
    label: s__('JH|PerformanceAnalytics|Closed MRs'),
    sortable: true,
    ...defaultFieldOption,
  },
  {
    key: 'notesCreated',
    label: s__('JH|PerformanceAnalytics|Comments'),
    sortable: true,
    ...defaultFieldOption,
  },
];

export const DEFAULT_PER_PAGE = 20;

export const DEFAULT_TABLE_CONFIG = {
  page: 1,
  sort: PERFORMANCE_TABLE_COLUMNS[0].key,
  direction: 'desc',
};

export const PERFORMANCE_TABLE_TITLE = s__('JH|Performance Report');
export const EXPORT_AS_CSV_BUTTON_TEXT = __('Export as CSV');
export const PREV = s__('Pagination|Previous');
export const NEXT = s__('Pagination|Next');
export const EMPTY_TABLE_TEXT = s__('JH|PerformanceAnalytics|No matches found');
export const ERROR_MSG = s__('JH|There was an error while fetching performance analytics data.');

export const BRANCH_SELECTOR_TIP = s__(
  'JH|PerformanceAnalytics|Branch selector only affect the number of code commits',
);

export const FROM_LABEL = __('From');
export const TO_LABEL = __('To');
