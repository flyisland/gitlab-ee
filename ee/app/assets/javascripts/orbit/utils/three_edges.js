// Renders edge connections as geodesic arcs on the globe surface, with animated impulse particles.
import * as THREE from 'three';
import { GRAPH_DEFAULTS } from '../constants';
import { IMPULSE_VERTEX_SHADER, IMPULSE_FRAGMENT_SHADER } from './graph_shaders';
import { easeInOutSine } from './graph_layout';
import { createEdgeLabelSprite } from './three_labels';
import { IMPULSE_COLOR, disposeGroupChildren } from './three_nodes';

const {
  GLOBE_RADIUS,
  NODE_HEIGHT,
  ARC_MIN_HEIGHT,
  CONNECTION_ARC_HEIGHT,
  EDGE_OPACITY,
  EDGE_CURVE_SEGMENTS,
  IMPULSE_SIZE,
  IMPULSE_BASE_SPEED,
  IMPULSE_SPEED_VARIANCE,
} = GRAPH_DEFAULTS;

const CONNECTION_COLOR_DARK = 0xffa726;
const CONNECTION_COLOR_LIGHT = 0x999999;
const LIGHT_MODE_EDGE_OPACITY = 0.5;

// Arc geometry thresholds
const ARC_ANGLE_THRESHOLD = 0.01;
const ARC_LONG_THRESHOLD_SEGMENTS = 4;
const ARC_SHORT_THRESHOLD_SEGMENTS = 2;

// 2D arrow sizing
const ARROW_OFFSET = 0.18;
const ARROW_RADIUS = 0.025;
const ARROW_HEIGHT = 0.07;
const ARROW_RADIAL_SEGMENTS = 4;
const ARROW_OPACITY_BOOST = 0.3;

/** Creates a straight LineCurve3 edge for 2D mode. */
export function createStraightLine(start, end) {
  return new THREE.LineCurve3(start, end);
}

/** Angle in radians between two direction vectors. */
function angleBetween(start, end) {
  const dot = start.clone().normalize().dot(end.clone().normalize());
  return Math.acos(Math.max(-1, Math.min(1, dot)));
}

/** Short-arc fallback: midpoint-elevated quadratic bezier for near-coincident points. */
function createShortArc(start, end) {
  const mid = start.clone().add(end).multiplyScalar(0.5);
  mid.normalize().multiplyScalar(GLOBE_RADIUS * ARC_MIN_HEIGHT);
  return new THREE.QuadraticBezierCurve3(start, mid, end);
}

/** Builds SLERP-interpolated control points for a CatmullRom spline arc. */
function buildSplineControlPoints(angle, start, end) {
  const startDir = start.clone().normalize();
  const endDir = end.clone().normalize();
  const sinAngle = Math.sin(angle);
  const arcHeight = Math.max(
    ARC_MIN_HEIGHT,
    NODE_HEIGHT + CONNECTION_ARC_HEIGHT * (angle / Math.PI),
  );
  const numSegments =
    angle > Math.PI / 2 ? ARC_LONG_THRESHOLD_SEGMENTS : ARC_SHORT_THRESHOLD_SEGMENTS;
  const controlPoints = [start.clone()];

  for (let i = 1; i < numSegments; i += 1) {
    const t = i / numSegments;
    const ctrlDir = startDir
      .clone()
      .multiplyScalar(Math.sin((1 - t) * angle) / sinAngle)
      .add(endDir.clone().multiplyScalar(Math.sin(t * angle) / sinAngle));

    const heightFactor = Math.sin(t * Math.PI);
    const pointHeight = NODE_HEIGHT + (arcHeight - NODE_HEIGHT) * heightFactor;
    controlPoints.push(ctrlDir.clone().multiplyScalar(GLOBE_RADIUS * pointHeight));
  }

  controlPoints.push(end.clone());
  return controlPoints;
}

/**
 * Creates a curved arc between two points on the globe surface.
 * Short arcs use a quadratic bezier; longer arcs use a CatmullRom spline
 * with height proportional to angular distance.
 */
export function createArcCurve(start, end) {
  const angle = angleBetween(start, end);
  if (angle < ARC_ANGLE_THRESHOLD) return createShortArc(start, end);

  const controlPoints = buildSplineControlPoints(angle, start, end);
  return new THREE.CatmullRomCurve3(controlPoints, false, 'catmullrom', 0.5);
}

/** Creates an animated point-sprite particle that travels along an edge curve. */
export function createImpulse(connection, renderer) {
  const geometry = new THREE.BufferGeometry();
  geometry.setAttribute('position', new THREE.Float32BufferAttribute([0, 0, 0], 3));

  const material = new THREE.ShaderMaterial({
    uniforms: {
      color: { value: IMPULSE_COLOR.clone() },
      pixelRatio: { value: renderer.getPixelRatio() },
      size: { value: IMPULSE_SIZE },
    },
    vertexShader: IMPULSE_VERTEX_SHADER,
    fragmentShader: IMPULSE_FRAGMENT_SHADER,
    transparent: false,
    depthTest: true,
    depthWrite: false,
  });

  const points = new THREE.Points(geometry, material);
  const startProgress = Math.random();
  const startPoint = connection.curve.getPoint(easeInOutSine(startProgress));
  points.position.copy(startPoint);

  return {
    mesh: points,
    connection,
    linearProgress: startProgress,
    baseSpeed: IMPULSE_BASE_SPEED + Math.random() * IMPULSE_SPEED_VARIANCE,
    direction: Math.random() > 0.5 ? 1 : -1,
  };
}

function clearConnectionGroups(connectionsGroup, impulsesGroup, labelsGroup) {
  disposeGroupChildren(connectionsGroup);
  disposeGroupChildren(impulsesGroup);
  disposeGroupChildren(labelsGroup);
  connectionsGroup.clear();
  impulsesGroup.clear();
  labelsGroup.clear();
}

function buildEdgeLine({ startPos, endPos, darkMode, flat }) {
  const connectionColor = darkMode ? CONNECTION_COLOR_DARK : CONNECTION_COLOR_LIGHT;
  const curve = flat ? createStraightLine(startPos, endPos) : createArcCurve(startPos, endPos);
  const curvePoints = curve.getPoints(EDGE_CURVE_SEGMENTS);
  const geometry = new THREE.BufferGeometry().setFromPoints(curvePoints);
  const material = new THREE.LineBasicMaterial({
    color: connectionColor,
    transparent: true,
    opacity: darkMode ? EDGE_OPACITY : LIGHT_MODE_EDGE_OPACITY,
    depthTest: true,
    depthWrite: false,
  });
  const line = new THREE.Line(geometry, material);
  return { line, curve, connectionColor };
}

function buildDirectionalArrow(startPos, endPos, connectionColor) {
  const dir = endPos.clone().sub(startPos).normalize();
  const arrowPos = endPos.clone().sub(dir.clone().multiplyScalar(ARROW_OFFSET));
  const arrow = new THREE.Mesh(
    new THREE.ConeGeometry(ARROW_RADIUS, ARROW_HEIGHT, ARROW_RADIAL_SEGMENTS),
    new THREE.MeshBasicMaterial({
      color: connectionColor,
      transparent: true,
      opacity: EDGE_OPACITY + ARROW_OPACITY_BOOST,
      depthTest: false,
    }),
  );
  arrow.position.copy(arrowPos);
  arrow.quaternion.setFromUnitVectors(new THREE.Vector3(0, 1, 0), dir);
  return arrow;
}

/** Builds edge lines, directional arrows (2D), and impulse particles (3D) for all edges. */
export function buildConnections({
  edges,
  nodes,
  darkMode,
  renderer,
  connectionsGroup,
  impulsesGroup,
  labelsGroup,
  flat = false,
}) {
  clearConnectionGroups(connectionsGroup, impulsesGroup, labelsGroup);

  const connections = [];
  const impulses = [];
  const usedPairs = new Set();

  edges.forEach((edge) => {
    const nodeA = nodes[edge.source];
    const nodeB = nodes[edge.target];
    if (!nodeA?.position || !nodeB?.position || edge.source === edge.target) return;

    const key = `${Math.min(edge.source, edge.target)}-${Math.max(edge.source, edge.target)}`;
    if (usedPairs.has(key)) return;
    usedPairs.add(key);

    const startPos = new THREE.Vector3(nodeA.position.x, nodeA.position.y, nodeA.position.z);
    const endPos = new THREE.Vector3(nodeB.position.x, nodeB.position.y, nodeB.position.z);

    const { line, curve, connectionColor } = buildEdgeLine({ startPos, endPos, darkMode, flat });
    const connection = { line, curve, source: edge.source, target: edge.target, arrow: null };
    connections.push(connection);
    connectionsGroup.add(line);

    if (flat) {
      connection.arrow = buildDirectionalArrow(startPos, endPos, connectionColor);
      connectionsGroup.add(connection.arrow);
    }

    if (!flat) {
      const impulse = createImpulse(connection, renderer);
      impulses.push(impulse);
      impulsesGroup.add(impulse.mesh);
    }

    if (edge.type) {
      const label = createEdgeLabelSprite(edge.type, darkMode);
      const midpoint = curve.getPoint(0.5);
      label.position.copy(midpoint);
      label.visible = false;
      connection.label = label;
      labelsGroup.add(label);
    }
  });

  return { connections, impulses };
}
