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
    it('returns only namespace, title and filters', async () => {
      obj = await fetch({
        namespace,
        title,
        query: { filters: { excludeMetrics: ['some metric'] } },
      });

      expect(obj).toStrictEqual({
        namespace,
        title,
        filters: { excludeMetrics: ['some metric'] },
      });
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
  });
});
