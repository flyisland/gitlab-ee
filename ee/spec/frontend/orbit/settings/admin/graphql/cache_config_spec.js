import { ADMIN_CACHE_CONFIG } from 'ee/orbit/settings/admin/graphql/cache_config';

describe('ADMIN_CACHE_CONFIG', () => {
  const { merge } = ADMIN_CACHE_CONFIG.typePolicies.Query.fields.knowledgeGraphExcludedNamespaces;
  const page = (ids) => ({ nodes: ids.map((id) => ({ __ref: `Group:${id}` })) });

  describe('when a page with a cursor loads', () => {
    it('appends the page to the loaded pages', () => {
      expect(merge(page([1]), page([2]), { args: { after: 'c1' } })).toEqual(page([1, 2]));
    });
  });

  describe('when a refetch loads the first page', () => {
    it('replaces the loaded pages', () => {
      expect(merge(page([1, 2]), page([3]), { args: {} })).toEqual(page([3]));
    });
  });

  describe('when a later page returns no data', () => {
    it('keeps the loaded pages', () => {
      expect(merge(page([1]), null, { args: { after: 'c1' } })).toEqual(page([1]));
    });
  });

  describe('when the cache is empty', () => {
    it('uses the incoming page', () => {
      expect(merge(undefined, page([1]), { args: { after: 'c1' } })).toEqual(page([1]));
    });
  });
});
