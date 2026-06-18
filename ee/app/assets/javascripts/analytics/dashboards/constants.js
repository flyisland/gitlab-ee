import { s__, __ } from '~/locale';
import { helpPagePath } from '~/helpers/help_page_helper';
import {
  FLOW_METRICS,
  DORA_METRICS,
  VULNERABILITY_METRICS,
  MERGE_REQUEST_METRICS,
  CONTRIBUTOR_METRICS,
  PIPELINE_ANALYTICS_METRICS,
  UNITS,
} from '~/analytics/shared/constants';
import { TABLE_METRICS } from '~/analytics/dashboards/constants';

export {
  TREND_STYLE_ASC,
  TREND_STYLE_DESC,
  TREND_STYLE_NONE,
  TREND_STYLES,
  PIPELINE_ANALYTICS_TABLE_METRICS,
  DORA_TABLE_METRICS,
  TABLE_METRICS,
} from '~/analytics/dashboards/constants';

export { DATA_TABLE_METRICS } from './ai_impact/constants';

export const SUPPORTED_DORA_METRICS = [
  DORA_METRICS.DEPLOYMENT_FREQUENCY,
  DORA_METRICS.LEAD_TIME_FOR_CHANGES,
  DORA_METRICS.TIME_TO_RESTORE_SERVICE,
  DORA_METRICS.CHANGE_FAILURE_RATE,
];

export const SUPPORTED_FLOW_METRICS = [
  FLOW_METRICS.LEAD_TIME,
  FLOW_METRICS.CYCLE_TIME,
  FLOW_METRICS.ISSUES,
  FLOW_METRICS.ISSUES_COMPLETED,
  FLOW_METRICS.DEPLOYS,
  FLOW_METRICS.MEDIAN_TIME_TO_MERGE,
];

export const SUPPORTED_MERGE_REQUEST_METRICS = [MERGE_REQUEST_METRICS.THROUGHPUT];

export const SUPPORTED_VULNERABILITY_METRICS = [
  VULNERABILITY_METRICS.CRITICAL,
  VULNERABILITY_METRICS.HIGH,
];

export const SUPPORTED_CONTRIBUTOR_METRICS = [CONTRIBUTOR_METRICS.COUNT];

export const SUPPORTED_PIPELINE_ANALYTICS_METRICS = [
  PIPELINE_ANALYTICS_METRICS.COUNT,
  PIPELINE_ANALYTICS_METRICS.SUCCESS_RATE,
  PIPELINE_ANALYTICS_METRICS.FAILURE_RATE,
  PIPELINE_ANALYTICS_METRICS.OTHER_RATE,
  PIPELINE_ANALYTICS_METRICS.MEDIAN,
];

export const METRICS_WITH_NO_TREND = [VULNERABILITY_METRICS.CRITICAL, VULNERABILITY_METRICS.HIGH];
export const METRICS_WITH_LABEL_FILTERING = [
  FLOW_METRICS.ISSUES,
  FLOW_METRICS.ISSUES_COMPLETED,
  FLOW_METRICS.CYCLE_TIME,
  FLOW_METRICS.LEAD_TIME,
  MERGE_REQUEST_METRICS.THROUGHPUT,
];
export const METRICS_WITHOUT_LABEL_FILTERING = Object.keys(TABLE_METRICS).filter(
  (metric) => !METRICS_WITH_LABEL_FILTERING.includes(metric),
);

export const DASHBOARD_LOADING_FAILURE = s__('DORA4Metrics|Some metric comparisons failed to load');
export const DASHBOARD_LABELS_LOAD_ERROR = s__(
  'DORA4Metrics|Failed to load labels matching the filter: %{labels}',
);
export const RESTRICTED_METRIC_ERROR = s__(
  'DORA4Metrics|You have insufficient permissions to view',
);
export const GENERIC_DASHBOARD_ERROR = s__('DORA4Metrics|Failed to load dashboard panel.');
export const UNSUPPORTED_PROJECT_NAMESPACE_ERROR = s__(
  'DORA4Metrics|This visualization is not supported for project namespaces.',
);
export const DASHBOARD_NO_DATA_FOR_GROUP = s__(
  'DORA4Metrics|No data available for Group: %{fullPath}',
);

export const CHART_LOADING_FAILURE = s__('DORA4Metrics|Some metric charts failed to load');

export const CHART_TOOLTIP_UNITS = {
  [UNITS.COUNT]: undefined,
  [UNITS.BIGINT_COUNT]: undefined,
  [UNITS.DAYS]: __('days'),
  [UNITS.PER_DAY]: __('/day'),
  [UNITS.PERCENT]: '%',
  [UNITS.MINUTES]: __('minutes'),
};

export const BACKGROUND_AGGREGATION_WARNING_TITLE = s__(
  'DORA4Metrics|Background aggregation not enabled',
);

export const ENABLE_BACKGROUND_AGGREGATION_WARNING_TEXT = s__(
  'DORA4Metrics|To see usage overview, you must %{linkStart}enable background aggregation%{linkEnd}.',
);

export const BACKGROUND_AGGREGATION_DOCS_LINK = helpPagePath(
  'user/analytics/value_streams_dashboard.html',
  { anchor: 'enable-or-disable-overview-background-aggregation' },
);
