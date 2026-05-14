import { createStraightLine, createArcCurve, buildConnections } from 'ee/orbit/utils/three_edges';

const mockGetPoint = jest.fn(() => ({ x: 0, y: 0, z: 0, copy: jest.fn() }));
const mockGetPoints = jest.fn(() => []);

jest.mock('three', () => {
  const Vec3 = jest.fn(function MockV3(x = 0, y = 0, z = 0) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.clone = jest.fn(() => new Vec3(this.x, this.y, this.z));
    this.normalize = jest.fn(() => this);
    this.dot = jest.fn(() => 0.5);
    this.add = jest.fn(() => this);
    this.sub = jest.fn(() => this);
    this.multiplyScalar = jest.fn(() => this);
    this.copy = jest.fn();
    this.set = jest.fn();
  });

  const LineCurve3 = jest.fn(function MockLC3(start, end) {
    this.start = start;
    this.end = end;
    this.type = 'LineCurve3';
    this.getPoint = mockGetPoint;
    this.getPoints = mockGetPoints;
  });

  const QuadraticBezierCurve3 = jest.fn(function MockQBC3() {
    this.type = 'QuadraticBezierCurve3';
    this.getPoint = mockGetPoint;
    this.getPoints = mockGetPoints;
  });

  const CatmullRomCurve3 = jest.fn(function MockCRC3() {
    this.type = 'CatmullRomCurve3';
    this.getPoint = mockGetPoint;
    this.getPoints = mockGetPoints;
  });

  const BufferGeometry = jest.fn(function MockBG() {
    this.setAttribute = jest.fn();
    this.setFromPoints = jest.fn(() => this);
    this.dispose = jest.fn();
  });

  const LineBasicMaterial = jest.fn(function MockLBM() {
    this.opacity = 0.4;
  });

  const Line = jest.fn(function MockLine(geo, mat) {
    this.geometry = geo;
    this.material = mat;
  });

  const MeshBasicMaterial = jest.fn(function MockMBM() {
    this.opacity = 1;
  });

  const ConeGeometry = jest.fn();

  const Mesh = jest.fn(function MockMesh() {
    this.position = { copy: jest.fn(), set: jest.fn() };
    this.quaternion = { setFromUnitVectors: jest.fn() };
  });

  const Color = jest.fn(function MockColor(r, g, b) {
    this.r = r ?? 0;
    this.g = g ?? 0;
    this.b = b ?? 0;
    this.clone = jest.fn(() => new Color(this.r, this.g, this.b));
  });

  const ShaderMaterial = jest.fn();
  const Float32BufferAttribute = jest.fn();
  const Points = jest.fn(function MockPoints() {
    this.position = { copy: jest.fn() };
    this.material = { uniforms: { color: { value: new Color() } } };
  });

  return {
    Vector3: Vec3,
    LineCurve3,
    QuadraticBezierCurve3,
    CatmullRomCurve3,
    BufferGeometry,
    LineBasicMaterial,
    Line,
    MeshBasicMaterial,
    ConeGeometry,
    Mesh,
    Color,
    ShaderMaterial,
    Float32BufferAttribute,
    Points,
  };
});

jest.mock('ee/orbit/utils/three_labels', () => ({
  createEdgeLabelSprite: jest.fn(() => ({
    position: { copy: jest.fn() },
    visible: true,
    material: { opacity: 1 },
  })),
}));

jest.mock('ee/orbit/utils/three_nodes', () => ({
  IMPULSE_COLOR: { r: 1, g: 0.85, b: 0.5, clone: jest.fn(() => ({ r: 1, g: 0.85, b: 0.5 })) },
  disposeGroupChildren: jest.fn(),
}));

jest.mock('ee/orbit/utils/graph_shaders', () => ({
  IMPULSE_VERTEX_SHADER: 'mock_vert',
  IMPULSE_FRAGMENT_SHADER: 'mock_frag',
}));

const createMockGroup = () => ({
  children: [],
  add: jest.fn(function mockAdd(child) {
    this.children.push(child);
  }),
  clear: jest.fn(function mockClear() {
    this.children = [];
  }),
});

describe('three_edges', () => {
  describe('createStraightLine', () => {
    it('returns a LineCurve3', () => {
      const THREE = jest.requireMock('three');
      const start = new THREE.Vector3(0, 0, 0);
      const end = new THREE.Vector3(1, 1, 0);

      const curve = createStraightLine(start, end);

      expect(curve.type).toBe('LineCurve3');
    });
  });

  describe('createArcCurve', () => {
    it('returns a curve object', () => {
      const THREE = jest.requireMock('three');
      const start = new THREE.Vector3(1, 0, 0);
      const end = new THREE.Vector3(0, 1, 0);

      const curve = createArcCurve(start, end);

      expect(curve).toBeDefined();
      expect(curve.getPoint).toBeDefined();
    });
  });

  describe('buildConnections', () => {
    it('creates connections and adds lines to the group', () => {
      const nodes = [
        { position: { x: 1, y: 0, z: 0 }, connections: new Set([1]) },
        { position: { x: 0, y: 1, z: 0 }, connections: new Set([0]) },
      ];
      const edges = [{ source: 0, target: 1, type: 'AUTHORED' }];
      const connectionsGroup = createMockGroup();
      const impulsesGroup = createMockGroup();
      const labelsGroup = createMockGroup();
      const renderer = { getPixelRatio: jest.fn(() => 1) };

      const result = buildConnections({
        edges,
        nodes,
        darkMode: true,
        renderer,
        connectionsGroup,
        impulsesGroup,
        labelsGroup,
        flat: true,
      });

      expect(result.connections).toHaveLength(1);
      expect(connectionsGroup.add).toHaveBeenCalled();
    });

    it('creates arrow cones in flat mode', () => {
      const THREE = jest.requireMock('three');
      const nodes = [
        { position: { x: 0, y: 0, z: 0 }, connections: new Set([1]) },
        { position: { x: 5, y: 0, z: 0 }, connections: new Set([0]) },
      ];
      const edges = [{ source: 0, target: 1, type: null }];
      const connectionsGroup = createMockGroup();

      const result = buildConnections({
        edges,
        nodes,
        darkMode: true,
        renderer: { getPixelRatio: jest.fn(() => 1) },
        connectionsGroup,
        impulsesGroup: createMockGroup(),
        labelsGroup: createMockGroup(),
        flat: true,
      });

      expect(result.connections[0].arrow).not.toBeNull();
      expect(THREE.Mesh).toHaveBeenCalled();
    });

    it('skips self-referencing edges', () => {
      const nodes = [{ position: { x: 0, y: 0, z: 0 }, connections: new Set() }];
      const edges = [{ source: 0, target: 0, type: 'SELF' }];

      const result = buildConnections({
        edges,
        nodes,
        darkMode: true,
        renderer: { getPixelRatio: jest.fn(() => 1) },
        connectionsGroup: createMockGroup(),
        impulsesGroup: createMockGroup(),
        labelsGroup: createMockGroup(),
        flat: true,
      });

      expect(result.connections).toHaveLength(0);
    });

    it('deduplicates edges between the same pair', () => {
      const nodes = [
        { position: { x: 0, y: 0, z: 0 }, connections: new Set([1]) },
        { position: { x: 1, y: 0, z: 0 }, connections: new Set([0]) },
      ];
      const edges = [
        { source: 0, target: 1, type: 'A' },
        { source: 1, target: 0, type: 'B' },
      ];

      const result = buildConnections({
        edges,
        nodes,
        darkMode: true,
        renderer: { getPixelRatio: jest.fn(() => 1) },
        connectionsGroup: createMockGroup(),
        impulsesGroup: createMockGroup(),
        labelsGroup: createMockGroup(),
        flat: true,
      });

      expect(result.connections).toHaveLength(1);
    });
  });
});
