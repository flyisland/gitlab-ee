import mockAiMetricsZeroResponseData from 'test_fixtures/ee/graphql/analytics/dashboards/ai_impact/graphql/ai_metrics.query.graphql.zero_values.json';
import mockAiMetricsNullResponseData from 'test_fixtures/ee/graphql/analytics/dashboards/ai_impact/graphql/ai_metrics.query.graphql.null_values.json';
import mockAiMetricsResponseData from 'test_fixtures/ee/graphql/analytics/dashboards/ai_impact/graphql/ai_metrics.query.graphql.json';
import mockAgentFlowsUsersCountResponseData from 'test_fixtures/ee/graphql/analytics/dashboards/ai_impact/graphql/duo_agent_platform_agent_flows_users_count.query.graphql.json';
import mockAgentFlowsUsersCountEmptyResponseData from 'test_fixtures/ee/graphql/analytics/dashboards/ai_impact/graphql/duo_agent_platform_agent_flows_users_count.query.graphql.empty.json';
import { AI_METRICS } from '~/analytics/shared/constants';
import fetch from 'ee/analytics/analytics_dashboards/data_sources/ai_impact_over_time';
import { defaultClient } from 'ee/analytics/analytics_dashboards/graphql/client';
import {
  DATE_RANGE_OPTION_LAST_7_DAYS,
  DATE_RANGE_OPTION_LAST_30_DAYS,
} from 'ee/analytics/analytics_dashboards/components/filters/constants';
import CodeSuggestionsUsersCountQuery from 'ee/analytics/dashboards/ai_impact/graphql/code_suggestions_users_count.query.graphql';
import DuoUsedCountQuery from 'ee/analytics/dashboards/ai_impact/graphql/duo_used_count.query.graphql';
import DuoAgentPlatformChatsQuery from 'ee/analytics/dashboards/ai_impact/graphql/duo_agent_platform_chats.query.graphql';
import DuoAgentPlatformAgentFlowsUsersCountQuery from 'ee/analytics/dashboards/ai_impact/graphql/duo_agent_platform_agent_flows_users_count.query.graphql';

const INVALID_DATE_RANGE = 'invalid-range';
const mockNullNamespaceResponse = { data: { group: null, project: null } };

describe('AI Impact Over Time Data Source', () => {
  let res;

  const query = {
    metric: AI_METRICS.CODE_SUGGESTIONS_USERS_COUNT,
    dateRange: DATE_RANGE_OPTION_LAST_30_DAYS,
  };
  const namespace = 'cool namespace';
  const defaultParams = {
    namespace,
    query,
  };

  const mockResolvedQuery = (response = mockAiMetricsResponseData) =>
    jest.spyOn(defaultClient, 'query').mockResolvedValueOnce(response);

  const expectQueryWithVariables = (variables) =>
    expect(defaultClient.query).toHaveBeenCalledWith(
      expect.objectContaining({
        variables: expect.objectContaining(variables),
      }),
    );

  describe('fetch', () => {
    describe('default', () => {
      it('correctly applies query parameters', async () => {
        await mockResolvedQuery();
        res = await fetch({ namespace, query });

        expectQueryWithVariables({
          startDate: '2020-06-06',
          endDate: '2020-07-06',
          fullPath: namespace,
        });
      });

      it.each`
        metric                                                    | expectedQuery
        ${AI_METRICS.CODE_SUGGESTIONS_USERS_COUNT}                | ${CodeSuggestionsUsersCountQuery}
        ${AI_METRICS.DUO_USED_COUNT}                              | ${DuoUsedCountQuery}
        ${AI_METRICS.DUO_AGENT_PLATFORM_CHATS}                    | ${DuoAgentPlatformChatsQuery}
        ${AI_METRICS.DUO_AGENT_PLATFORM_AGENTS_FLOWS_USERS_COUNT} | ${DuoAgentPlatformAgentFlowsUsersCountQuery}
      `('sends the correct query for `$metric`', async ({ metric, expectedQuery }) => {
        mockResolvedQuery();
        await fetch({ namespace, query: { ...query, metric } });

        expect(defaultClient.query).toHaveBeenCalledWith(
          expect.objectContaining({ query: expectedQuery }),
        );
      });

      describe.each`
        type             | response                         | result
        ${'valid'}       | ${mockAiMetricsResponseData}     | ${'5'}
        ${'zero values'} | ${mockAiMetricsZeroResponseData} | ${'0'}
        ${'null values'} | ${mockAiMetricsNullResponseData} | ${'-'}
      `('with $type data', ({ response, result }) => {
        beforeEach(async () => {
          mockResolvedQuery(response);
          res = await fetch({ namespace, query });
        });

        it(`returns ${result}`, () => {
          expect(res).toBe(result);
        });
      });

      describe(`for ${AI_METRICS.DUO_AGENT_PLATFORM_AGENTS_FLOWS_USERS_COUNT} metric`, () => {
        describe.each`
          type                | response                                     | result
          ${'valid'}          | ${mockAgentFlowsUsersCountResponseData}      | ${'2'}
          ${'zero values'}    | ${mockAgentFlowsUsersCountEmptyResponseData} | ${'0'}
          ${'null namespace'} | ${mockNullNamespaceResponse}                 | ${'-'}
        `('with $type data', ({ response, result }) => {
          beforeEach(async () => {
            mockResolvedQuery(response);
            res = await fetch({
              namespace,
              query: {
                ...defaultParams.query,
                metric: AI_METRICS.DUO_AGENT_PLATFORM_AGENTS_FLOWS_USERS_COUNT,
              },
            });
          });

          it(`returns ${result}`, () => {
            expect(res).toBe(result);
          });
        });
      });
    });

    describe('setVisualizationOverrides callback', () => {
      let mockSetVisualizationOverrides;

      describe.each`
        metric                                                    | response
        ${AI_METRICS.CODE_SUGGESTIONS_USERS_COUNT}                | ${mockAiMetricsResponseData}
        ${AI_METRICS.DUO_AGENT_PLATFORM_CHATS}                    | ${mockAiMetricsResponseData}
        ${AI_METRICS.DUO_USED_COUNT}                              | ${mockAiMetricsResponseData}
        ${AI_METRICS.DUO_AGENT_PLATFORM_AGENTS_FLOWS_USERS_COUNT} | ${mockAgentFlowsUsersCountResponseData}
      `('for $metric metric', ({ metric, response }) => {
        beforeEach(async () => {
          mockSetVisualizationOverrides = jest.fn();
          mockResolvedQuery(response);
          res = await fetch({
            namespace,
            query: { ...defaultParams.query, metric },
            setVisualizationOverrides: mockSetVisualizationOverrides,
          });
        });

        it('will call the setVisualizationOverrides callback with the correct settings', () => {
          expect(mockSetVisualizationOverrides.mock.calls).toMatchSnapshot();
        });
      });
    });

    describe('queryOverrides', () => {
      const mockQuery = (
        dateRange,
        {
          namespace: namespaceParam = 'cool namespace',
          metric = AI_METRICS.CODE_SUGGESTIONS_USERS_COUNT,
        } = {},
      ) => {
        mockResolvedQuery();

        return fetch({
          ...defaultParams,
          query: { ...defaultParams.query, metric },
          queryOverrides: { dateRange, namespace: namespaceParam },
        });
      };

      it('can override the date range', async () => {
        res = await mockQuery(DATE_RANGE_OPTION_LAST_7_DAYS);

        expectQueryWithVariables({
          startDate: '2020-06-29',
          endDate: '2020-07-06',
          fullPath: namespace,
        });
      });

      it.each`
        metric                                     | result
        ${AI_METRICS.CODE_SUGGESTIONS_USERS_COUNT} | ${'5'}
        ${AI_METRICS.DUO_USED_COUNT}               | ${'3'}
        ${AI_METRICS.DUO_AGENT_PLATFORM_CHATS}     | ${'25'}
      `('can override the metric with `$metric`', async ({ metric, result }) => {
        res = await mockQuery(DATE_RANGE_OPTION_LAST_7_DAYS, { metric });

        expectQueryWithVariables({
          startDate: '2020-06-29',
          endDate: '2020-07-06',
          fullPath: namespace,
        });

        expect(res).toBe(result);
      });

      it('can override the namespace', async () => {
        res = await mockQuery(DATE_RANGE_OPTION_LAST_7_DAYS, {
          namespace: 'cool-namespace/sub-namespace',
        });

        expectQueryWithVariables({
          startDate: '2020-06-29',
          endDate: '2020-07-06',
          fullPath: 'cool-namespace/sub-namespace',
        });
      });

      it('will default to DATE_RANGE_OPTION_LAST_30_DAYS when given an invalid dateRange', async () => {
        res = await mockQuery(INVALID_DATE_RANGE);

        expectQueryWithVariables({
          startDate: '2020-06-06',
          endDate: '2020-07-06',
          fullPath: namespace,
        });

        const defaultRes = await mockQuery(DATE_RANGE_OPTION_LAST_30_DAYS);
        expect(defaultRes).toEqual(res);
      });
    });

    describe('unsupported metric', () => {
      it('throws an error', async () => {
        await expect(
          fetch({ namespace, query: { ...query, metric: 'unsupported_metric' } }),
        ).rejects.toThrow('No query found for metric: unsupported_metric');
      });
    });
  });
});
