/**
 * Positions graph nodes on a 3D sphere (or 2D plane) using type-based clustering,
 * force-directed attraction, and repulsion.
 * Pipeline: placeNodeClusters -> applyAttraction -> applyRepulsion.
 */
import { forceSimulation, forceLink, forceManyBody, forceCenter, forceCollide } from 'd3';
import { GRAPH_DEFAULTS, ENTITY_TYPE_COLORS } from '../constants';

const {
  GLOBE_RADIUS,
  NODE_HEIGHT,
  CLUSTER_SPREAD,
  MIN_NODE_DISTANCE,
  LAYOUT_ATTRACTION_ITERATIONS,
  LAYOUT_REPULSION_ITERATIONS,
} = GRAPH_DEFAULTS;

const SPHERE_RADIUS = GLOBE_RADIUS * NODE_HEIGHT;

// Normalize / vector thresholds
const ZERO_LENGTH_THRESHOLD = 0.0001;
const CROSS_PRODUCT_MIN_LENGTH = 0.1;

// Cluster layout tuning
const CLUSTER_RADIUS_MIN = 0.3;
const CLUSTER_RADIUS_VARIANCE = 0.7;
const SPREAD_LOG_MULTIPLIER = 0.5;

// Attraction / repulsion tuning
const SINGLE_NEIGHBOR_PULL = 0.8;
const MULTI_NEIGHBOR_PULL = 0.3;
const REPULSION_PUSH_FACTOR = 0.5;
const REPULSION_PUSH_MIN = 0.01;
const OVERLAP_THRESHOLD = 0.001;

// d3-force simulation parameters
const D3_LINK_DISTANCE_FACTOR = 0.6;
const D3_CHARGE_SMALL = -100;
const D3_CHARGE_LARGE = -200;
const D3_SMALL_GRAPH_THRESHOLD = 15;
const D3_SIMULATION_TICKS = 300;
const D3_COLLIDE_RADIUS_FACTOR = 0.35;

// --- Vector math primitives ---

/** Vector cross product of two {x, y, z} objects. */
export function cross(a, b) {
  return {
    x: a.y * b.z - a.z * b.y,
    y: a.z * b.x - a.x * b.z,
    z: a.x * b.y - a.y * b.x,
  };
}

/** Euclidean length of a {x, y, z} vector. */
export function vecLen(v) {
  return Math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
}

/** Normalize a {x, y, z} position to the given radius (target length). */
export function normalize(pos, radius) {
  const len = Math.sqrt(pos.x * pos.x + pos.y * pos.y + pos.z * pos.z);
  if (len < ZERO_LENGTH_THRESHOLD) return { x: 0, y: radius, z: 0 };
  const scale = radius / len;
  return { x: pos.x * scale, y: pos.y * scale, z: pos.z * scale };
}

/** Euclidean distance between two points after normalizing both to unit length. */
export function distance(a, b) {
  const na = normalize(a, 1);
  const nb = normalize(b, 1);
  const dx = na.x - nb.x;
  const dy = na.y - nb.y;
  const dz = na.z - nb.z;
  return Math.sqrt(dx * dx + dy * dy + dz * dz);
}

/** Linear interpolation between two {x, y, z} points by factor t. */
export function lerp(a, b, t) {
  return {
    x: a.x + (b.x - a.x) * t,
    y: a.y + (b.y - a.y) * t,
    z: a.z + (b.z - a.z) * t,
  };
}

// Assigns each entity type to a lat/lng anchor on the globe for visual clustering.
const DOMAIN_BASE_POSITIONS = {
  group: { lat: 0, lng: -90 },
  project: { lat: 30, lng: -60 },
  directory: { lat: 50, lng: -120 },
  file: { lat: 20, lng: -30 },
  class: { lat: -10, lng: -70 },
  interface: { lat: -10, lng: -110 },
  enum: { lat: 30, lng: -140 },
  method: { lat: -40, lng: -80 },
  constructor: { lat: -40, lng: -100 },
  import: { lat: -60, lng: -90 },
  code_review: { lat: 50, lng: -90 },
  planning: { lat: 20, lng: -40 },
  ci_cd: { lat: -20, lng: -60 },
  security: { lat: -20, lng: -120 },
  deployment: { lat: -50, lng: -80 },
  user: { lat: 40, lng: -50 },
  note: { lat: -30, lng: -50 },
  mergerequest: { lat: 10, lng: -110 },
  workitem: { lat: -15, lng: -70 },
  default: { lat: 0, lng: -90 },
};

function latLngToPosition(lat, lng, radius) {
  const phi = ((90 - lat) * Math.PI) / 180;
  const theta = ((lng + 180) * Math.PI) / 180;
  return {
    x: -radius * Math.sin(phi) * Math.cos(theta),
    y: radius * Math.cos(phi),
    z: radius * Math.sin(phi) * Math.sin(theta),
  };
}

// --- Graph traversal ---

/** Builds a bidirectional adjacency map from node indices and edges. */
export function buildAdjacencyMap(nodes, edges) {
  const adj = new Map();
  nodes.forEach((n, i) => adj.set(i, new Set()));
  edges.forEach((e) => {
    if (adj.has(e.source) && adj.has(e.target)) {
      adj.get(e.source).add(e.target);
      adj.get(e.target).add(e.source);
    }
  });
  return adj;
}

/** Breadth-first search from a node index. Returns Map of nodeIndex -> distance. */
export function runBFS(startIndex, adjacencyMap) {
  if (typeof startIndex !== 'number') {
    throw new TypeError(`runBFS: startIndex must be a number, got ${typeof startIndex}`);
  }
  if (!(adjacencyMap instanceof Map)) {
    throw new TypeError('runBFS: adjacencyMap must be a Map');
  }

  const distances = new Map();
  distances.set(startIndex, 0);
  const queue = [startIndex];
  let head = 0;

  while (head < queue.length) {
    const current = queue[head];
    head += 1;
    const currentDist = distances.get(current);
    const neighbors = adjacencyMap.get(current);
    if (neighbors) {
      neighbors.forEach((neighbor) => {
        if (!distances.has(neighbor)) {
          distances.set(neighbor, currentDist + 1);
          queue.push(neighbor);
        }
      });
    }
  }

  return distances;
}

// --- Layout algorithms ---

function resolveBasePosition(type, dynamicIndex, dynamicCount) {
  if (DOMAIN_BASE_POSITIONS[type]) return DOMAIN_BASE_POSITIONS[type];
  const angle = (dynamicIndex / Math.max(dynamicCount, 1)) * 360;
  return { lat: -70 + (dynamicIndex % 3) * 20, lng: -180 + angle };
}

function groupNodesByType(nodes) {
  const typeGroups = Object.create(null);
  nodes.forEach((node, i) => {
    const key = (node.type || node.domain || 'default').toLowerCase();
    if (!typeGroups[key]) typeGroups[key] = [];
    typeGroups[key].push(i);
  });
  return typeGroups;
}

function buildUnknownTypeIndex(types) {
  const unknownTypes = types.filter((t) => !DOMAIN_BASE_POSITIONS[t]);
  return { unknownTypes, unknownCount: unknownTypes.length };
}

function placeClusterRing(nodes, indices, center) {
  const centerNorm = normalize(center, 1);

  const up = { x: 0, y: 1, z: 0 };
  let t1 = cross(centerNorm, up);
  if (vecLen(t1) < CROSS_PRODUCT_MIN_LENGTH) {
    t1 = cross(centerNorm, { x: 1, y: 0, z: 0 });
  }
  t1 = normalize(t1, 1);
  const t2 = normalize(cross(centerNorm, t1), 1);

  const clusterSize = indices.length;
  const spreadScale = 1 + Math.log2(Math.max(clusterSize, 1)) * SPREAD_LOG_MULTIPLIER;
  for (let i = 0; i < clusterSize; i += 1) {
    const idx = indices[i];
    const angle = (i / clusterSize) * Math.PI * 2;
    const r =
      CLUSTER_SPREAD * spreadScale * (CLUSTER_RADIUS_MIN + Math.random() * CLUSTER_RADIUS_VARIANCE);
    const ox = Math.cos(angle) * r;
    const oy = Math.sin(angle) * r;

    const pos = {
      x: centerNorm.x + t1.x * ox + t2.x * oy,
      y: centerNorm.y + t1.y * ox + t2.y * oy,
      z: centerNorm.z + t1.z * ox + t2.z * oy,
    };
    nodes[idx].position = normalize(pos, SPHERE_RADIUS); // eslint-disable-line no-param-reassign -- mutates in-place by design
  }
}

/**
 * Groups nodes by entity type and places each cluster around its
 * assigned lat/lng anchor on the sphere.
 * @mutates nodes — positions are set in place for performance.
 */
export function placeNodeClusters(nodes) {
  const typeGroups = groupNodesByType(nodes);
  const types = Object.keys(typeGroups);
  const { unknownCount } = buildUnknownTypeIndex(types);
  let unknownIdx = 0;

  Object.entries(typeGroups).forEach(([type, indices]) => {
    let dynamicIdx = 0;
    if (!DOMAIN_BASE_POSITIONS[type]) {
      dynamicIdx = unknownIdx;
      unknownIdx += 1;
    }
    const basePos = resolveBasePosition(type, dynamicIdx, unknownCount);
    const center = latLngToPosition(basePos.lat, basePos.lng, SPHERE_RADIUS);
    placeClusterRing(nodes, indices, center);
  });
}

function averageNeighborPosition(nodes, neighbors) {
  const positions = [];
  neighbors.forEach((ni) => {
    if (nodes[ni].position) positions.push(nodes[ni].position);
  });
  if (positions.length === 0) return null;

  const avg = { x: 0, y: 0, z: 0 };
  positions.forEach((p) => {
    avg.x += p.x;
    avg.y += p.y;
    avg.z += p.z;
  });
  avg.x /= positions.length;
  avg.y /= positions.length;
  avg.z /= positions.length;
  return normalize(avg, SPHERE_RADIUS);
}

/**
 * Pulls connected nodes closer together on the sphere surface.
 * @mutates nodes — positions are set in place for performance.
 */
export function applyAttraction(nodes, adj) {
  for (let iter = 0; iter < LAYOUT_ATTRACTION_ITERATIONS; iter += 1) {
    for (let i = 0; i < nodes.length; i += 1) {
      const neighbors = adj.get(i);
      if (neighbors && neighbors.size > 0) {
        const target = averageNeighborPosition(nodes, neighbors);
        if (target) {
          const pull = neighbors.size === 1 ? SINGLE_NEIGHBOR_PULL : MULTI_NEIGHBOR_PULL;
          // eslint-disable-next-line no-param-reassign -- mutates in-place by design
          nodes[i].position = normalize(lerp(nodes[i].position, target, pull), SPHERE_RADIUS);
        }
      }
    }
  }
}

function computePushDirection(posA, posB, d) {
  if (d > OVERLAP_THRESHOLD) {
    const na = normalize(posA, 1);
    const nb = normalize(posB, 1);
    return normalize({ x: na.x - nb.x, y: na.y - nb.y, z: na.z - nb.z }, 1);
  }
  return normalize({ x: Math.random() - 0.5, y: Math.random() - 0.5, z: Math.random() - 0.5 }, 1);
}

function pushedPosition(pos, pushNorm, pushStrength) {
  return normalize(
    {
      x: pos.x + pushNorm.x * pushStrength * SPHERE_RADIUS,
      y: pos.y + pushNorm.y * pushStrength * SPHERE_RADIUS,
      z: pos.z + pushNorm.z * pushStrength * SPHERE_RADIUS,
    },
    SPHERE_RADIUS,
  );
}

/**
 * Pushes overlapping nodes apart to prevent visual collisions.
 * @mutates nodes — positions are set in place for performance.
 */
export function applyRepulsion(nodes) {
  for (let iter = 0; iter < LAYOUT_REPULSION_ITERATIONS; iter += 1) {
    for (let a = 0; a < nodes.length; a += 1) {
      if (nodes[a].position) {
        for (let b = a + 1; b < nodes.length; b += 1) {
          if (nodes[b].position) {
            const d = distance(nodes[a].position, nodes[b].position);
            if (d < MIN_NODE_DISTANCE) {
              const pushStrength =
                (MIN_NODE_DISTANCE - d) * REPULSION_PUSH_FACTOR + REPULSION_PUSH_MIN;
              const pushNorm = computePushDirection(nodes[a].position, nodes[b].position, d);
              nodes[a].position = pushedPosition(nodes[a].position, pushNorm, pushStrength); // eslint-disable-line no-param-reassign -- mutates in-place by design
            }
          }
        }
      }
    }
  }
}

/**
 * Main entry point: positions all nodes on the globe by type cluster,
 * then refines with attraction/repulsion passes.
 * @mutates nodes — positions are set in place for performance.
 */
export function computeSphereLayout(nodes, edges) {
  const adj = buildAdjacencyMap(nodes, edges);
  placeNodeClusters(nodes);
  applyAttraction(nodes, adj);
  applyRepulsion(nodes);
}

function buildSimulationInput(nodes, edges, incremental) {
  const spread = SPHERE_RADIUS;
  const simNodes = nodes.map((n, i) => {
    const hasFlat = incremental && n.position && n.position.z === 0;
    return {
      index: i,
      x: hasFlat ? n.position.x : (Math.random() - 0.5) * spread * 2,
      y: hasFlat ? n.position.y : (Math.random() - 0.5) * spread * 2,
    };
  });
  const simLinks = (edges || []).map((e) => ({ source: e.source, target: e.target }));
  return { simNodes, simLinks };
}

function runD3Simulation(simNodes, simLinks, nodeCount) {
  const simulation = forceSimulation(simNodes)
    .force(
      'link',
      forceLink(simLinks)
        .id((d) => d.index)
        .distance(SPHERE_RADIUS * D3_LINK_DISTANCE_FACTOR),
    )
    .force(
      'charge',
      forceManyBody().strength(
        nodeCount < D3_SMALL_GRAPH_THRESHOLD ? D3_CHARGE_SMALL : D3_CHARGE_LARGE,
      ),
    )
    .force('center', forceCenter(0, 0))
    .force('collide', forceCollide(SPHERE_RADIUS * D3_COLLIDE_RADIUS_FACTOR).strength(1))
    .stop();

  for (let i = 0; i < D3_SIMULATION_TICKS; i += 1) simulation.tick();
}

function scaleSimResultsToNodes(nodes, simNodes) {
  let maxExtent = 0;
  for (const sn of simNodes) {
    maxExtent = Math.max(maxExtent, Math.abs(sn.x), Math.abs(sn.y));
  }
  const targetRadius = SPHERE_RADIUS;
  const scale = maxExtent > targetRadius ? targetRadius / maxExtent : 1;

  for (let i = 0; i < simNodes.length; i += 1) {
    nodes[i].position = { x: simNodes[i].x * scale, y: simNodes[i].y * scale, z: 0 }; // eslint-disable-line no-param-reassign -- mutates in-place by design
  }
}

/**
 * Positions nodes using a d3-force simulation for a proper 2D graph layout.
 * @mutates nodes — positions are set in place for performance.
 */
export function computeFlatLayout(nodes, edges, { incremental = false } = {}) {
  const { simNodes, simLinks } = buildSimulationInput(nodes, edges, incremental);
  runD3Simulation(simNodes, simLinks, nodes.length);
  scaleSimResultsToNodes(nodes, simNodes);
}

// --- Node styling ---

/**
 * Resolves a node's display color from its type, falling back to the default palette.
 * The first fallback (|| 'default') handles missing type/domain.
 * The second fallback (|| .default) handles types not in the color map.
 */
export function getNodeColor(node) {
  const key = (node.type || node.domain || 'default').toLowerCase();
  return ENTITY_TYPE_COLORS[key] || ENTITY_TYPE_COLORS.default;
}

/** Sinusoidal ease-in-out for smooth camera and impulse animation. */
export function easeInOutSine(t) {
  return -(Math.cos(Math.PI * t) - 1) / 2;
}
