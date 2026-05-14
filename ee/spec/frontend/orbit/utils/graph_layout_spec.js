import {
  computeSphereLayout,
  computeFlatLayout,
  buildAdjacencyMap,
  runBFS,
  getNodeColor,
} from 'ee/orbit/utils/graph_layout';

describe('graph_layout', () => {
  const createNodes = (count) =>
    Array.from({ length: count }, (_, i) => ({
      id: String(i),
      type: i % 2 === 0 ? 'class' : 'method',
      domain: i % 3 === 0 ? 'code_review' : 'planning',
      position: null,
      connections: new Set(),
    }));

  const createEdges = (pairs) =>
    pairs.map(([source, target]) => ({ source, target, type: 'test' }));

  describe('computeSphereLayout', () => {
    it('assigns positions to all nodes', () => {
      const nodes = createNodes(10);
      const edges = createEdges([
        [0, 1],
        [1, 2],
        [2, 3],
      ]);

      computeSphereLayout(nodes, edges);

      nodes.forEach((node) => {
        expect(node.position).toBeDefined();
        expect(node.position.x).toBeDefined();
        expect(node.position.y).toBeDefined();
        expect(node.position.z).toBeDefined();
      });
    });

    it('places nodes on the sphere surface', () => {
      const nodes = createNodes(5);
      const edges = createEdges([[0, 1]]);

      computeSphereLayout(nodes, edges);

      nodes.forEach((node) => {
        const { x, y, z } = node.position;
        const radius = Math.sqrt(x * x + y * y + z * z);
        expect(radius).toBeGreaterThan(0);
      });
    });

    it('clusters nodes by domain', () => {
      let seed = 0.42;
      const mockRandom = jest.spyOn(Math, 'random').mockImplementation(() => {
        seed = (seed * 9301 + 49297) % 233280;
        return seed / 233280;
      });

      const nodes = [
        { id: '0', type: 'class', domain: 'code_review', position: null, connections: new Set() },
        { id: '1', type: 'class', domain: 'code_review', position: null, connections: new Set() },
        { id: '2', type: 'method', domain: 'planning', position: null, connections: new Set() },
        { id: '3', type: 'method', domain: 'planning', position: null, connections: new Set() },
      ];
      const edges = [];

      computeSphereLayout(nodes, edges);

      const dist01 = Math.sqrt(
        (nodes[0].position.x - nodes[1].position.x) ** 2 +
          (nodes[0].position.y - nodes[1].position.y) ** 2 +
          (nodes[0].position.z - nodes[1].position.z) ** 2,
      );
      const dist02 = Math.sqrt(
        (nodes[0].position.x - nodes[2].position.x) ** 2 +
          (nodes[0].position.y - nodes[2].position.y) ** 2 +
          (nodes[0].position.z - nodes[2].position.z) ** 2,
      );

      expect(dist01).toBeLessThan(dist02);

      mockRandom.mockRestore();
    });
  });

  describe('computeFlatLayout', () => {
    it('assigns z=0 to all nodes', () => {
      const nodes = createNodes(5);

      computeFlatLayout(nodes);

      nodes.forEach((node) => {
        expect(node.position).toBeDefined();
        expect(node.position.z).toBe(0);
      });
    });
  });

  describe('buildAdjacencyMap', () => {
    it('creates correct adjacency sets', () => {
      const nodes = createNodes(3);
      const edges = createEdges([
        [0, 1],
        [1, 2],
      ]);

      const adj = buildAdjacencyMap(nodes, edges);

      expect(adj.get(0)).toEqual(new Set([1]));
      expect(adj.get(1)).toEqual(new Set([0, 2]));
      expect(adj.get(2)).toEqual(new Set([1]));
    });
  });

  describe('runBFS', () => {
    it('returns distance 0 for start node', () => {
      const nodes = createNodes(3);
      const edges = createEdges([
        [0, 1],
        [1, 2],
      ]);
      const adj = buildAdjacencyMap(nodes, edges);

      const distances = runBFS(0, adj);

      expect(distances.get(0)).toBe(0);
    });

    it('returns correct hop distances', () => {
      const nodes = createNodes(4);
      const edges = createEdges([
        [0, 1],
        [1, 2],
        [2, 3],
      ]);
      const adj = buildAdjacencyMap(nodes, edges);

      const distances = runBFS(0, adj);

      expect(distances.get(0)).toBe(0);
      expect(distances.get(1)).toBe(1);
      expect(distances.get(2)).toBe(2);
      expect(distances.get(3)).toBe(3);
    });

    it('does not include disconnected nodes', () => {
      const nodes = createNodes(4);
      const edges = createEdges([[0, 1]]);
      const adj = buildAdjacencyMap(nodes, edges);

      const distances = runBFS(0, adj);

      expect(distances.has(0)).toBe(true);
      expect(distances.has(1)).toBe(true);
      expect(distances.has(2)).toBe(false);
      expect(distances.has(3)).toBe(false);
    });
  });

  describe('getNodeColor', () => {
    it('returns color for known types', () => {
      expect(getNodeColor({ type: 'class' })).toBe('#A78BFA');
      expect(getNodeColor({ type: 'method' })).toBe('#EF4444');
    });

    it('returns default color for unknown types', () => {
      expect(getNodeColor({ type: 'unknown_type' })).toBe('#6B7280');
    });

    it('uses domain over type when available', () => {
      expect(getNodeColor({ domain: 'MergeRequest', type: 'class' })).toBe('#A78BFA');
    });
  });
});
