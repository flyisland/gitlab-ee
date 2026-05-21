import ThreeGraph3D from 'ee/orbit/utils/three_graph_3d';

const mockSceneInstance = {
  init: jest.fn(),
  dispose: jest.fn(),
  setMode2D: jest.fn(),
  setMode3D: jest.fn(),
  resize: jest.fn(),
  render: jest.fn(),
  scene: { add: jest.fn() },
  camera: {
    fov: 45,
    position: {
      set: jest.fn(),
      copy: jest.fn(() => mockSceneInstance.camera.position),
      add: jest.fn(() => mockSceneInstance.camera.position),
      sub: jest.fn(() => ({ length: jest.fn(() => 10), setLength: jest.fn() })),
      clone: jest.fn(() => ({
        sub: jest.fn(() => ({ length: jest.fn(() => 10), setLength: jest.fn() })),
      })),
      lerpVectors: jest.fn(),
      length: jest.fn(() => 50),
      x: 0,
      y: 0,
      z: 50,
    },
    lookAt: jest.fn(),
  },
  renderer: { getPixelRatio: jest.fn(() => 2) },
  controls: {
    update: jest.fn(),
    target: { set: jest.fn() },
    minDistance: 1,
    maxDistance: 100,
  },
};

jest.mock('ee/orbit/utils/three_scene', () => {
  function MockGraphScene() {
    Object.assign(this, mockSceneInstance);
  }
  MockGraphScene.CAMERA_DEFAULT_Z = 50;
  return {
    __esModule: true,
    default: MockGraphScene,
    CAMERA_DEFAULT_Z: 50,
  };
});

const mockInteraction = {
  attach: jest.fn(),
  detach: jest.fn(),
  setContext: jest.fn(),
  onNodeHover: jest.fn(),
  onNodeSelect: jest.fn(),
  onNodeExpand: jest.fn(),
  onNodeSelectCallback: jest.fn(),
  hoveredNode: null,
};

jest.mock('ee/orbit/utils/three_interaction_3d', () => {
  return jest.fn().mockImplementation(() => mockInteraction);
});

jest.mock('ee/orbit/utils/three_globe', () => ({
  createGlobe: jest.fn(),
  createCityLights: jest.fn(),
}));

jest.mock('ee/orbit/utils/three_nodes', () => ({
  buildNodeMarkers: jest.fn(() => ({
    nodeGeometry: { dispose: jest.fn() },
    nodeMaterial: { dispose: jest.fn() },
    nodeMarkers: {},
    originalNodeColors: [],
    originalNodeSizes: [],
  })),
  highlightSubgraph: jest.fn(),
  highlightByTypes: jest.fn(),
  resetHighlighting: jest.fn(),
  NODE_LABEL_OFFSET: 0.1,
}));

jest.mock('ee/orbit/utils/three_edges_3d', () => ({
  buildGlobeConnections: jest.fn(() => ({ connections: [], impulses: [] })),
}));

jest.mock('ee/orbit/utils/three_labels', () => ({
  clearLabelCache: jest.fn(),
}));

jest.mock('ee/orbit/utils/graph_layout', () => ({
  computeSphereLayout: jest.fn(),
  buildAdjacencyMap: jest.fn(() => new Map()),
  easeInOutSine: jest.fn((t) => t),
}));

jest.mock('three', () => ({
  Group: function MockGroup() {
    this.add = jest.fn();
    this.remove = jest.fn();
    this.children = [];
    this.renderOrder = 0;
    this.rotation = { y: 0 };
  },
  Vector3: function Vec3(x = 0, y = 0, z = 0) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.set = jest.fn();
    this.clone = jest.fn(() => new Vec3(this.x, this.y, this.z));
    this.length = jest.fn(() => Math.sqrt(x * x + y * y + z * z));
  },
}));

describe('ThreeGraph3D', () => {
  let container;
  let graph;

  beforeEach(() => {
    jest.clearAllMocks();
    global.requestAnimationFrame = jest.fn();
    global.cancelAnimationFrame = jest.fn();
    container = document.createElement('div');
  });

  describe('constructor', () => {
    it('initializes with empty data and the given options', () => {
      graph = new ThreeGraph3D(container, { darkMode: false });

      expect(graph.nodes).toEqual([]);
      expect(graph.edges).toEqual([]);
      expect(graph.darkMode).toBe(false);
      expect(graph.active).toBe(true);
    });

    it('defaults darkMode to true', () => {
      graph = new ThreeGraph3D(container);

      expect(graph.darkMode).toBe(true);
    });
  });

  describe('init', () => {
    beforeEach(() => {
      graph = new ThreeGraph3D(container);
      graph.init();
    });

    it('switches the scene to 3D mode', () => {
      expect(mockSceneInstance.setMode3D).toHaveBeenCalled();
    });

    it('creates the globe and city lights', () => {
      // eslint-disable-next-line global-require
      const { createGlobe, createCityLights } = require('ee/orbit/utils/three_globe');
      expect(createGlobe).toHaveBeenCalled();
      expect(createCityLights).toHaveBeenCalled();
    });

    it('attaches the interaction handler', () => {
      expect(mockInteraction.attach).toHaveBeenCalled();
    });

    it('replays pending callbacks registered before init', () => {
      const hoverCb = jest.fn();
      const fresh = new ThreeGraph3D(container);

      fresh.onNodeHover(hoverCb);
      fresh.init();

      expect(mockInteraction.onNodeHover).toHaveBeenCalledWith(hoverCb);
    });
  });

  describe('setData', () => {
    beforeEach(() => {
      graph = new ThreeGraph3D(container);
      graph.init();
    });

    it('stores indexed nodes with empty connection sets', () => {
      const nodes = [
        { id: 'a', label: 'A' },
        { id: 'b', label: 'B' },
      ];

      graph.setData(nodes, [{ source: 0, target: 1 }]);

      expect(graph.nodes).toHaveLength(2);
      expect(graph.nodes[0].connections.has(1)).toBe(true);
    });
  });

  describe('searchNodes', () => {
    beforeEach(() => {
      graph = new ThreeGraph3D(container);
      graph.init();
      graph.setData(
        [
          { id: 'User_1', label: 'Administrator', type: 'user' },
          { id: 'User_2', label: 'Developer', type: 'user' },
          { id: 'Group_1', label: 'gitlab-org', type: 'group' },
        ],
        [],
      );
    });

    it('returns an empty list when the query is empty or too short', () => {
      expect(graph.searchNodes('a')).toEqual([]);
    });

    it('matches against label/id/type case-insensitively', () => {
      expect(graph.searchNodes('user')).toHaveLength(2);
      expect(graph.searchNodes('GITLAB-ORG')).toHaveLength(1);
    });
  });

  describe('selectNode / deselectNode', () => {
    beforeEach(() => {
      graph = new ThreeGraph3D(container);
      graph.init();
      graph.setData(
        [
          { id: 'a', label: 'A' },
          { id: 'b', label: 'B' },
        ],
        [],
      );
    });

    it('selectNode stores the node and fires the select callback', () => {
      graph.selectNode(0);

      expect(graph.selectedNode).toBe(graph.nodes[0]);
      expect(mockInteraction.onNodeSelectCallback).toHaveBeenCalledWith(graph.nodes[0]);
    });

    it('deselectNode resets the selection and fires the callback with null', () => {
      [graph.selectedNode] = graph.nodes;
      graph.deselectNode();

      expect(graph.selectedNode).toBeNull();
      expect(mockInteraction.onNodeSelectCallback).toHaveBeenCalledWith(null);
    });
  });

  describe('dispose', () => {
    beforeEach(() => {
      graph = new ThreeGraph3D(container);
      graph.init();
    });

    it('marks the graph inactive and disposes the scene + interaction', () => {
      graph.dispose();

      expect(graph.active).toBe(false);
      expect(mockInteraction.detach).toHaveBeenCalled();
      expect(mockSceneInstance.dispose).toHaveBeenCalled();
    });
  });
});
