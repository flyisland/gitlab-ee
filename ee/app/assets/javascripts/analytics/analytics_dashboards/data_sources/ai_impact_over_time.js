import { isNil } from 'lodash-es';
import { formatNumber, s__, sprintf } from '~/locale';
import CodeSuggestionsUsersCountQuery from 'ee/analytics/dashboards/ai_impact/graphql/code_suggestions_users_count.query.graphql';
import DuoUsedCountQuery from 'ee/analytics/dashboards/ai_impact/graphql/duo_used_count.query.graphql';
import DuoAgentPlatformChatsQuery from 'ee/analytics/dashboards/ai_impact/graphql/duo_agent_platform_chats.query.graphql';
import DuoAgentPlatformAgentFlowsUsersCountQuery from 'ee/analytics/dashboards/ai_impact/graphql/duo_agent_platform_agent_flows_users_count.query.graphql';
import { AI_IMPACT_OVER_TIME_METRICS_TOOLTIPS } from 'ee/analytics/dashboards/ai_impact/constants';
import { DATE_RANGE_OPTION_LAST_30_DAYS } from 'ee/analytics/analytics_dashboards/components/filters/constants';
import { getDateRange } from 'ee/analytics/analytics_dashboards/components/filters/utils';
import { toISODateFormat } from '~/lib/utils/datetime_utility';
import { AI_METRICS } from '~/analytics/shared/constants';
import { extractQueryResponseFromNamespace } from '~/analytics/shared/utils';
import { extractAiMetricsResponse } from 'ee/analytics/dashboards/ai_impact/api';
import { defaultClient } from '../graphql/client';

const METRIC_QUERIES = {
  [AI_METRICS.CODE_SUGGESTIONS_USERS_COUNT]: CodeSuggestionsUsersCountQuery,
  [AI_METRICS.DUO_USED_COUNT]: DuoUsedCountQuery,
  [AI_METRICS.DUO_AGENT_PLATFORM_CHATS]: DuoAgentPlatformChatsQuery,
  [AI_METRICS.DUO_AGENT_PLATFORM_AGENTS_FLOWS_USERS_COUNT]:
    DuoAgentPlatformAgentFlowsUsersCountQuery,
};

const extractMetricData = ({ metric, rawQueryResult: result }) => {
  const resp = extractAiMetricsResponse(result);

  switch (metric) {
    case AI_METRICS.CODE_SUGGESTIONS_USERS_COUNT: {
      const {
        codeSuggestions: { contributorsCount: codeSuggestionsContributorsCount },
      } = resp;

      return codeSuggestionsContributorsCount;
    }

    case AI_METRICS.DUO_USED_COUNT: {
      const { duoUsedCount } = resp;

      return duoUsedCount;
    }

    case AI_METRICS.DUO_AGENT_PLATFORM_CHATS: {
      const { agentPlatformChats: { startedSessionEventCount } = {} } = resp;

      return startedSessionEventCount;
    }

    case AI_METRICS.DUO_AGENT_PLATFORM_AGENTS_FLOWS_USERS_COUNT: {
      const analyticsResponse = extractQueryResponseFromNamespace({
        result,
        resultKey: 'analytics',
      });

      return analyticsResponse?.agentPlatformSessions?.aggregated?.nodes?.[0]?.usersCount;
    }

    default:
      return null;
  }
};

const fetchAiImpactQuery = async ({ metric, namespace, startDate, endDate }) => {
  const query = METRIC_QUERIES[metric];

  if (!query) {
    throw new Error(
      sprintf(s__('AiImpactAnalytics|No query found for metric: %{metric}'), { metric }),
    );
  }

  const rawQueryResult = await defaultClient.query({
    query,
    variables: {
      fullPath: namespace,
      startDate,
      endDate,
    },
  });

  const value = extractMetricData({ metric, rawQueryResult });

  return isNil(value) ? '-' : formatNumber(value);
};

export default async function fetch({
  namespace,
  query: { metric, dateRange = DATE_RANGE_OPTION_LAST_30_DAYS },
  queryOverrides: { dateRange: dateRangeOverride = null, ...overridesRest } = {},
  setVisualizationOverrides = () => {},
}) {
  // Default to 30 days if an invalid date range is given
  const dateRangeOption = getDateRange(
    dateRangeOverride || dateRange,
    DATE_RANGE_OPTION_LAST_30_DAYS,
  );

  const { startDate, endDate, text: subtitle } = dateRangeOption;
  const value = await fetchAiImpactQuery({
    startDate: toISODateFormat(startDate, true),
    endDate: toISODateFormat(endDate, true),
    metric,
    namespace,
    ...overridesRest,
  });

  setVisualizationOverrides({
    visualizationOptionOverrides: {
      subtitle,
      tooltip: AI_IMPACT_OVER_TIME_METRICS_TOOLTIPS[metric],
    },
  });

  return value;
}
