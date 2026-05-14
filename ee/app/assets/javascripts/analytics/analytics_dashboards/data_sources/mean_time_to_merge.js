import { dayAfter } from '~/lib/utils/datetime_utility';
import { queryThroughputData } from 'ee/analytics/merge_request_analytics/api';
import {
  computeMttmData,
  filterToMRThroughputQueryObject,
} from 'ee/analytics/merge_request_analytics/utils';
import { DATE_RANGE_OPTION_LAST_365_DAYS } from 'ee/analytics/analytics_dashboards/components/filters/constants';
import { getDateRange } from 'ee/analytics/analytics_dashboards/components/filters/utils';

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

  const { value = 0 } = computeMttmData(rawData);
  return value;
}
