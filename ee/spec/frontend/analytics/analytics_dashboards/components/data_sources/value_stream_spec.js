import fetch from 'ee/analytics/analytics_dashboards/data_sources/value_stream';

describe('Value Stream Data Source', () => {
  let obj;

  const namespace = 'cool namespace';
  const title = 'fake title';

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
