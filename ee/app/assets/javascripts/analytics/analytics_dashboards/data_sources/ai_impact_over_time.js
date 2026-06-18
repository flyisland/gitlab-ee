import { isNil } from 'lodash-es';
import { formatNumber, s__, sprintf } from '~/locale';
import DuoUsedCountQuery from 'ee/analytics/dashboards/ai_impact/graphql/duo_used_count.query.graphql';
import DuoAgentPlatformChatsQuery from 'ee/analytics/dashboards/ai_impact/graphql/duo_agent_platform_chats.query.graphql';
import DuoAgentPlatformAgentFlowsUsersCountQuery from 'ee/analytics/dashboards/ai_impact/graphql/duo_agent_platform_agent_flows_users_count.query.graphql';
import DuoPowerUsersCountQuery from 'ee/analytics/dashboards/ai_impact/graphql/duo_power_users_count.query.graphql';
import { AI_IMPACT_OVER_TIME_METRICS_TOOLTIPS } from 'ee/analytics/dashboards/ai_impact/constants';
import { DATE_RANGE_OPTION_LAST_30_DAYS } from 'ee/analytics/analytics_dashboards/components/filters/constants';
import { getDateRange } from '~/explore/analytics_dashboards/components/utils';
import { toISODateFormat } from '~/lib/utils/datetime_utility';
import { AI_METRICS } from '~/analytics/shared/constants';
import { extractQueryResponseFromNamespace } from '~/analytics/shared/utils';
import { extractAiMetricsResponse } from 'ee/analytics/dashboards/ai_impact/api';
import { calculateChange, getBadgeTrendIndicator } from 'ee/analytics/dashboards/ai_impact/utils';
import { defaultClient } from '../graphql/client';

const METRIC_QUERIES = {
  [AI_METRICS.DUO_USED_COUNT]: DuoUsedCountQuery,
  [AI_METRICS.DUO_AGENT_PLATFORM_CHATS]: DuoAgentPlatformChatsQuery,
  [AI_METRICS.DUO_AGENT_PLATFORM_AGENTS_FLOWS_USERS_COUNT]:
    DuoAgentPlatformAgentFlowsUsersCountQuery,
  [AI_METRICS.DUO_POWER_USERS_COUNT]: DuoPowerUsersCountQuery,
};

const extractMetricData = ({ metric, result }) => {
  const resp = extractAiMetricsResponse(result);

  switch (metric) {
    case AI_METRICS.DUO_USED_COUNT: {
      const { duoUsedCount } = resp;

      return duoUsedCount;
    }

    case AI_METRICS.DUO_AGENT_PLATFORM_CHATS: {
      const { agentPlatformChats: { createdSessionEventCount } = {} } = resp;

      return createdSessionEventCount;
    }

    case AI_METRICS.DUO_AGENT_PLATFORM_AGENTS_FLOWS_USERS_COUNT: {
      const analyticsResponse = extractQueryResponseFromNamespace({
        result,
        resultKey: 'analytics',
      });

      return analyticsResponse?.agentPlatformSessions?.aggregated?.nodes?.[0]?.usersCount;
    }

    case AI_METRICS.DUO_POWER_USERS_COUNT: {
      const analyticsResponse = extractQueryResponseFromNamespace({
        result,
        resultKey: 'analytics',
      });

      return analyticsResponse?.duoUsageEvents?.aggregated?.count;
    }

    default:
      return null;
  }
};

const fetchMetric = async ({ metric, namespace, startDate, endDate }) => {
  const query = METRIC_QUERIES[metric];

  if (!query) {
    throw new Error(
      sprintf(s__('AiImpactAnalytics|No query found for metric: %{metric}'), { metric }),
    );
  }

  const result = await defaultClient.query({
    query,
    variables: {
      fullPath: namespace,
      startDate: toISODateFormat(startDate, true),
      endDate: toISODateFormat(endDate, true),
    },
  });

  return extractMetricData({ metric, result });
};

const fetchAiImpactQuery = async ({ metric, namespace, startDate, endDate, previousRange }) => {
  const currentValue = await fetchMetric({ metric, namespace, startDate, endDate });
  const previousValue = await fetchMetric({ metric, namespace, ...previousRange });

  return { currentValue, previousValue };
};

export default async function fetch({
  namespace,
  query: { metric, dateRange, ...overridesRest } = {},
  setVisualizationOverrides = () => {},
}) {
  // Default to 30 days if an invalid date range is given
  const {
    startDate,
    endDate,
    previousRange,
    text: subtitle,
  } = getDateRange(dateRange, DATE_RANGE_OPTION_LAST_30_DAYS);

  const { currentValue, previousValue } = await fetchAiImpactQuery({
    metric,
    namespace,
    startDate,
    endDate,
    previousRange,
    ...overridesRest,
  });

  const { value: change, tooltip: metaTooltip } = calculateChange(currentValue, previousValue, {
    validValueTooltip: s__(
      'AiImpactAnalytics|Percentage change compared to the previous time period.',
    ),
    noPreviousDataTooltip: s__(
      "AiImpactAnalytics|Value can't be calculated due to insufficient data. No data is available for the previous time period.",
    ),
  });

  setVisualizationOverrides({
    visualizationOptionOverrides: {
      subtitle,
      tooltip: AI_IMPACT_OVER_TIME_METRICS_TOOLTIPS[metric],
      metaTooltip,
      ...getBadgeTrendIndicator({ change }),
    },
  });

  return isNil(currentValue) ? '-' : formatNumber(currentValue);
}
