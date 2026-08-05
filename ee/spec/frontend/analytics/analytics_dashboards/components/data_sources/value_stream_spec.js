import fetch from 'ee/analytics/analytics_dashboards/data_sources/value_stream';
import { defaultClient } from 'ee/analytics/analytics_dashboards/graphql/client';

describe('Value Stream Data Source', () => {
  let obj;

  const namespace = 'cool namespace';
  const title = 'fake title';

  const mockNamespaceResponse = {
    data: { project: null, group: { name: namespace, id: '1' } },
  };

  beforeEach(() => {
    jest.spyOn(defaultClient, 'query').mockResolvedValue(mockNamespaceResponse);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('fetch', () => {
    it('returns namespace, title, and all allowed filter fields', async () => {
      const filters = {
        includeMetrics: ['metric_a'],
        excludeMetrics: ['metric_b'],
        labels: ['bug'],
        projectTopics: ['frontend'],
      };

      obj = await fetch({ namespace, title, query: { filters } });

      expect(obj).toStrictEqual({ namespace, title, filters });
    });

    it('drops arbitrary query fields', async () => {
      obj = await fetch({
        namespace,
        title,
        query: { filters: { excludeMetrics: [] }, foo: 'bar', baz: { key: 'value' } },
      });

      expect(obj).toStrictEqual({
        namespace,
        title,
        filters: { excludeMetrics: [] },
      });
    });

    it('drops arbitrary filter sub-fields', async () => {
      obj = await fetch({
        namespace,
        title,
        query: {
          filters: { excludeMetrics: ['metric_a'], foo: 'bar', baz: { key: 'value' } },
        },
      });

      expect(obj).toStrictEqual({
        namespace,
        title,
        filters: { excludeMetrics: ['metric_a'] },
      });
    });
  });
});
