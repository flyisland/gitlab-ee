import { dayAfter } from '~/lib/utils/datetime_utility';
import { queryThroughputData } from 'ee/analytics/merge_request_analytics/api';
import {
  filterToMRThroughputQueryObject,
  formatThroughputChartData,
} from 'ee/analytics/merge_request_analytics/utils';
import { DATE_RANGE_OPTION_LAST_365_DAYS } from 'ee/analytics/analytics_dashboards/components/filters/constants';
import { getDateRange } from 'ee/analytics/analytics_dashboards/components/filters/utils';

const responseHasAnyData = (rawData) => Object.values(rawData).some(({ count }) => count);

export default async function fetch({
  namespace,
  query: { dateRange = DATE_RANGE_OPTION_LAST_365_DAYS } = {},
  queryOverrides: { dateRange: dateRangeOverride = null, ...overridesRest } = {},
  filters: {
    startDate: filtersStartDate,
    endDate: filtersEndDate,
    searchFilters,
    dateRangeOption,
  } = {},
  setVisualizationOverrides = () => {},
}) {
  const dateRangeKey = dateRangeOption || dateRangeOverride || dateRange;
  const {
    startDate,
    endDate,
    text: subtitle,
  } = getDateRange(dateRangeKey, DATE_RANGE_OPTION_LAST_365_DAYS);

  setVisualizationOverrides({ visualizationOptionOverrides: { subtitle } });

  const rawData = await queryThroughputData({
    namespace,
    startDate: filtersStartDate ?? startDate,
    endDate: filtersEndDate ?? dayAfter(endDate, { utc: true }),
    ...filterToMRThroughputQueryObject(searchFilters),
    ...overridesRest,
  });

  if (!responseHasAnyData(rawData)) {
    // return an empty object so the correct dashboard "empty state" is rendered
    return {};
  }

  return formatThroughputChartData(rawData);
}
