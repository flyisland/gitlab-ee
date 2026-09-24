import { s__, __, sprintf } from '~/locale';

export const ACTIVITY_METRICS = [
  {
    key: 'code_lines',
    title: s__('JH|PerformanceMeasurement|Lines of code'),
  },
  {
    key: 'active_points',
    title: s__('JH|PerformanceMeasurement|Active level'),
  },
  {
    key: 'create_issues',
    title: s__('JH|PerformanceMeasurement|Issue(s) created'),
  },
  {
    key: 'issue_comments',
    title: s__('JH|PerformanceMeasurement|Issue(s) commented'),
  },
  {
    key: 'commits',
    title: s__('JH|PerformanceMeasurement|Commits'),
  },
  {
    key: 'create_merge_requests',
    title: s__('JH|PerformanceMeasurement|MR(s) created'),
  },
  {
    key: 'review_merge_requests',
    title: s__('JH|PerformanceMeasurement|MR(s) reviewed'),
  },
  {
    key: 'merge_request_comments',
    title: s__('JH|PerformanceMeasurement|MR(s) commented'),
  },
];

export const STATISTICS_I18N = {
  activityMetricsTitle: s__('JH|PerformanceMeasurement|Activity metrics'),
  validityRatioTitle: s__('JH|PerformanceMeasurement|Code validity ratio'),
  codeQualityTitle: s__('JH|PerformanceMeasurement|Code quality'),
};

export const SUMMARY_HEADER_I18N = {
  titles: {
    time: __('Time'),
    groupOrProject: s__('JH|PerformanceMeasurement|Select group or project'),
    branch: __('Branch'),
    member: __('Member'),
    shortcut: s__('JH|PerformanceMeasurement|Shortcut'),
  },
  placeholders: {
    all: __('All'),
    loading: __('Loading'),
  },
  resetLabel: __('Reset'),
  multipleSelectedLabel: s__(
    'JH|PerformanceMeasurement|%{firstSelectedName} + %{selectedLength} more',
  ),
};

export const DATE_RANGE_PICKER_SHORTCUTS = [
  {
    value: 'custom',
    text: s__('JH|PerformanceMeasurement|Customized'),
  },
  {
    value: 'last_7_days',
    text: sprintf(__('Last %{days} days'), { days: 7 }),
  },
  {
    value: 'last_14_days',
    text: sprintf(__('Last %{days} days'), { days: 14 }),
  },
  {
    value: 'last_30_days',
    text: sprintf(__('Last %{days} days'), { days: 30 }),
  },
  {
    value: 'last_60_days',
    text: sprintf(__('Last %{days} days'), { days: 60 }),
  },
  {
    value: 'last_90_days',
    text: sprintf(__('Last %{days} days'), { days: 90 }),
  },
  {
    value: 'last_180_days',
    text: sprintf(__('Last %{days} days'), { days: 180 }),
  },
];

export const CHART_TABS = [
  {
    title: s__('JH|PerformanceMeasurement|Active level'),
    value: 'activity',
  },
  {
    title: __('Issues'),
    value: 'issues',
  },
  {
    title: s__('JH|PerformanceMeasurement|Efficiency'),
    value: 'efficiency',
  },
  {
    title: s__('JH|PerformanceMeasurement|Commits'),
    value: 'commits',
  },
  {
    title: __('Merge requests'),
    value: 'code_validity_ratio',
  },
];

export const CHART_RANGE_OPTIONS = [
  {
    text: __('Days'),
    value: 'day',
  },
  {
    text: __('Weeks'),
    value: 'week',
  },
  {
    text: __('Month'),
    value: 'month',
  },
];

export const TABLE_COLUMNS = [
  {
    key: 'gitlab_user',
    label: __('Member'),
    sortable: true,
  },
  {
    key: 'active_points',
    label: s__('JH|PerformanceMeasurement|Active level'),
    sortable: true,
  },
  {
    key: 'created_issues_count',
    label: s__('JH|PerformanceMeasurement|Issue(s) created'),
    sortable: true,
  },
  {
    key: 'code_lines_count',
    label: s__('JH|PerformanceMeasurement|Lines of code'),
    sortable: true,
  },
  {
    key: 'commits_count',
    label: s__('JH|PerformanceMeasurement|Commits'),
    sortable: true,
  },
  {
    key: 'created_merge_requests_count',
    label: s__('JH|PerformanceMeasurement|MR(s) created'),
    sortable: true,
  },
];
