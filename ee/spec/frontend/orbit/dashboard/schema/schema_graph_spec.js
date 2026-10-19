import { DEFAULT_NODE_COLOR } from 'ee/orbit/constants';
import {
  entityNeighbors,
  entityRelationships,
  filterDomains,
  formatItemCount,
  groupByEntity,
  itemCount,
  normalizeSchema,
  placementStyle,
  ringPositions,
  scaleFromCenter,
  schemaDomains,
} from 'ee/orbit/dashboard/schema/schema_graph';
import { mockExpandedSchema } from '../../mock_data';

describe('schema_graph', () => {
  describe('filterDomains', () => {
    const domains = schemaDomains(mockExpandedSchema);
    const names = (filtered) => filtered.map((d) => [d.key, d.entities.map((e) => e.name)]);

    it('keeps every domain for an empty or blank search', () => {
      expect(filterDomains(domains, '  ')).toBe(domains);
    });

    it('keeps matching entities, ignores case, and drops empty domains', () => {
      expect(names(filterDomains(domains, ' JOB '))).toEqual([['ci', ['Job']]]);
    });

    it('keeps every entity of a domain whose label matches', () => {
      expect(names(filterDomains(domains, 'pipelines'))).toEqual([
        ['ci', ['Job', 'Pipeline', 'Stage']],
      ]);
    });
  });

  describe('itemCount', () => {
    it.each`
      itemCounts            | expected
      ${{ pipeline: 1200 }} | ${1200}
      ${{ pipeline: 0 }}    | ${0}
      ${{}}                 | ${null}
      ${null}               | ${null}
    `('finds Pipeline in $itemCounts as $expected', ({ itemCounts, expected }) => {
      expect(itemCount(itemCounts, 'Pipeline')).toBe(expected);
    });
  });

  describe('formatItemCount', () => {
    it.each`
      itemCounts            | name          | expected
      ${{ pipeline: 1200 }} | ${'Pipeline'} | ${'1,200'}
      ${{ pipeline: 0 }}    | ${'Pipeline'} | ${'0'}
      ${{}}                 | ${'Pipeline'} | ${''}
      ${null}               | ${'Pipeline'} | ${''}
    `('formats $name in $itemCounts as "$expected"', ({ itemCounts, name, expected }) => {
      expect(formatItemCount(itemCounts, name)).toBe(expected);
    });
  });

  describe('schemaDomains', () => {
    it('orders the domains and names them with the domain labels', () => {
      expect(schemaDomains(mockExpandedSchema).map((domain) => [domain.key, domain.label])).toEqual(
        [
          ['core', 'Projects'],
          ['ci', 'Pipelines'],
        ],
      );
    });

    it('opens each domain on its main entity, with its color', () => {
      expect(schemaDomains(mockExpandedSchema)).toMatchObject([
        { entryEntity: 'Project', color: '#06b6d4', icon: 'project' },
        { entryEntity: 'Pipeline', color: '#f59e0b', icon: 'pipeline' },
      ]);
    });

    it('puts unknown domains last, sorted, named by their key', () => {
      const schema = {
        nodes: [
          { name: 'Zeta', domain: 'zeta' },
          { name: 'Alpha', domain: 'alpha' },
          { name: 'Package', domain: 'packages' },
        ],
      };

      expect(schemaDomains(schema).map((domain) => [domain.label, domain.entryEntity])).toEqual([
        ['Packages', 'Package'],
        ['alpha', 'Alpha'],
        ['zeta', 'Zeta'],
      ]);
    });

    it('returns no domains for a schema without nodes', () => {
      expect(schemaDomains(normalizeSchema({}))).toEqual([]);
    });

    it('gives an entity without a style or a known icon the default color and no icon', () => {
      const [domain] = schemaDomains({ nodes: [{ name: 'Mystery', domain: 'other' }] });

      expect(domain.entities).toEqual([{ name: 'Mystery', icon: null, color: DEFAULT_NODE_COLOR }]);
    });
  });

  describe('entityRelationships', () => {
    it('splits relationships by direction', () => {
      expect(entityRelationships(mockExpandedSchema, 'Pipeline')).toEqual({
        outgoing: [{ edge: 'CONTAINS', description: 'Containment relationship', entity: 'Stage' }],
        incoming: [{ edge: 'AUTHORED', description: 'Authorship relationship', entity: 'User' }],
      });
    });

    it('counts a self relationship as outgoing only', () => {
      const schema = {
        nodes: [{ name: 'Issue' }],
        edges: [{ name: 'MENTIONS', variants: [{ source_type: 'Issue', target_type: 'Issue' }] }],
      };

      expect(entityRelationships(schema, 'Issue')).toEqual({
        outgoing: [{ edge: 'MENTIONS', description: undefined, entity: 'Issue' }],
        incoming: [],
      });
    });

    it('drops relationships to entities that are not schema nodes', () => {
      const schema = {
        ...mockExpandedSchema,
        edges: [
          ...mockExpandedSchema.edges,
          { name: 'USES', variants: [{ source_type: 'Pipeline', target_type: 'Unknown' }] },
          { name: 'OWNS', variants: [{ source_type: 'Ghost', target_type: 'Pipeline' }] },
        ],
      };

      expect(entityRelationships(schema, 'Pipeline')).toEqual(
        entityRelationships(mockExpandedSchema, 'Pipeline'),
      );
    });
  });

  it('groups relationships by the other entity and drops repeated names', () => {
    const groups = groupByEntity([
      { entity: 'User', edge: 'AUTHORED', description: 'a' },
      { entity: 'User', edge: 'MERGED', description: 'm' },
      { entity: 'User', edge: 'AUTHORED', description: 'a' },
    ]);

    expect(groups).toEqual([
      {
        entity: 'User',
        edges: [
          { name: 'AUTHORED', description: 'a' },
          { name: 'MERGED', description: 'm' },
        ],
      },
    ]);
  });

  describe('entityNeighbors', () => {
    const domains = schemaDomains(mockExpandedSchema);

    it('lists the other entities in domain order, each with all its relationships', () => {
      const relationships = {
        outgoing: [
          { edge: 'CONTAINS', entity: 'Stage' },
          { edge: 'MENTIONS', entity: 'Pipeline' },
        ],
        incoming: [
          { edge: 'AUTHORED', entity: 'User' },
          { edge: 'MERGED', entity: 'User' },
        ],
      };

      expect(entityNeighbors({ domains, relationships, name: 'Pipeline' })).toEqual([
        {
          name: 'User',
          icon: 'user',
          color: '#ec4899',
          edges: [
            { name: 'AUTHORED', description: undefined },
            { name: 'MERGED', description: undefined },
          ],
        },
        {
          name: 'Stage',
          icon: 'stage-all',
          color: '#fbbf24',
          edges: [{ name: 'CONTAINS', description: undefined }],
        },
      ]);
    });
  });

  it('places the first point on top and pulls every second point inward in alternate mode', () => {
    const [first, second] = ringPositions(4, 40, { alternate: true });

    expect(first.x).toBeCloseTo(50);
    expect(first.y).toBeCloseTo(10);
    expect(second.x).toBeCloseTo(80);
    expect(second.y).toBeCloseTo(50);
  });

  it('moves a point toward the center by a factor', () => {
    expect(scaleFromCenter({ x: 90, y: 10 }, 0.5)).toEqual({ x: 70, y: 30 });
  });

  it('gives a schema without nodes or edges empty lists', () => {
    expect(normalizeSchema({ schema_version: 'v1' })).toEqual({
      schema_version: 'v1',
      nodes: [],
      edges: [],
    });
  });

  it('turns a ring point into a position style in percent', () => {
    expect(placementStyle({ x: 12.5, y: 80 })).toEqual({ left: '12.5%', top: '80%' });
  });
});
