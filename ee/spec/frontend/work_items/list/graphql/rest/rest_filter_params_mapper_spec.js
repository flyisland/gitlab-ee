import { convertGraphQLVarsToRestParams } from 'ee/work_items/list/graphql/rest/rest_filter_params_mapper';

describe('EE convertGraphQLVarsToRestParams', () => {
  describe('health status filter', () => {
    it.each([
      ['onTrack', 'on_track'],
      ['needsAttention', 'needs_attention'],
      ['atRisk', 'at_risk'],
    ])('maps healthStatusFilter %s to health_status_filter %s', (input, expected) => {
      const params = convertGraphQLVarsToRestParams({ healthStatusFilter: input });

      expect(params.get('health_status_filter')).toBe(expected);
    });

    it.each([
      ['NONE', 'none'],
      ['ANY', 'any'],
    ])('maps wildcard healthStatusFilter %s to health_status_filter %s', (input, expected) => {
      const params = convertGraphQLVarsToRestParams({ healthStatusFilter: input });

      expect(params.get('health_status_filter')).toBe(expected);
    });

    it('passes through unknown health status values unchanged', () => {
      const params = convertGraphQLVarsToRestParams({ healthStatusFilter: 'something_else' });

      expect(params.get('health_status_filter')).toBe('something_else');
    });

    it('omits health_status_filter when not provided', () => {
      expect(convertGraphQLVarsToRestParams({}).get('health_status_filter')).toBeNull();
    });
  });

  describe('negated health status filter', () => {
    it('maps not.healthStatusFilter scalar value to not[health_status_filter]', () => {
      const params = convertGraphQLVarsToRestParams({ not: { healthStatusFilter: 'atRisk' } });

      expect(params.get('not[health_status_filter]')).toBe('at_risk');
    });

    it('maps not.healthStatusFilter array values to not[health_status_filter][]', () => {
      const params = convertGraphQLVarsToRestParams({
        not: { healthStatusFilter: ['atRisk', 'onTrack'] },
      });

      expect(params.getAll('not[health_status_filter][]')).toEqual(['at_risk', 'on_track']);
    });

    it('does not emit not[health_status_filter] when value is missing', () => {
      const params = convertGraphQLVarsToRestParams({ not: {} });

      expect(params.get('not[health_status_filter]')).toBeNull();
    });

    it('only emits one not[health_status_filter] parameter', () => {
      const params = convertGraphQLVarsToRestParams({
        not: { healthStatusFilter: 'atRisk' },
      });

      expect(params.getAll('not[health_status_filter]')).toHaveLength(1);
    });
  });

  describe('unioned health status filter', () => {
    it('maps or.healthStatusFilter scalar value to or[health_status_filter]', () => {
      const params = convertGraphQLVarsToRestParams({ or: { healthStatusFilter: 'onTrack' } });

      expect(params.get('or[health_status_filter]')).toBe('on_track');
    });

    it('maps or.healthStatusFilter array values to or[health_status_filter][]', () => {
      const params = convertGraphQLVarsToRestParams({
        or: { healthStatusFilter: ['atRisk', 'needsAttention'] },
      });

      expect(params.getAll('or[health_status_filter][]')).toEqual(['at_risk', 'needs_attention']);
    });
  });
});
