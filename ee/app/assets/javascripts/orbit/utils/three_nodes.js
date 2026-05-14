// Builds Three.js point-sprite markers for graph nodes and handles BFS-based subgraph highlighting.
import * as THREE from 'three';
import { GRAPH_DEFAULTS } from '../constants';
import { NODE_VERTEX_SHADER, NODE_FRAGMENT_SHADER } from './graph_shaders';
import { runBFS, getNodeColor } from './graph_layout';
import { createNodeLabelSprite } from './three_labels';

const { NODE_BASE_SIZE, EDGE_OPACITY, BFS_OPACITY_DECAY, BFS_MIN_OPACITY } = GRAPH_DEFAULTS;

export const NODE_LABEL_OFFSET = 0.18;
const IMPULSE_COLOR = new THREE.Color(1.0, 0.85, 0.5);
const LIGHT_MODE_FADE = 0.88;
const LIGHT_MODE_COLOR_MIX = 0.3;
const DISCONNECTED_EDGE_OPACITY = 0.08;

// Node sizing
const NODE_SIZE_SCALE = 0.55;
const CONNECTION_SIZE_BOOST = 8;
const MAX_COUNT_SCALE = 1.8;
const COUNT_SCALE_DIVISOR = 10;
const LABEL_OFFSET_SCALE_FACTOR = 0.4;

// BFS highlight tuning
const BFS_EDGE_OPACITY_SCALE = 0.6;
const DISCONNECTED_LABEL_OPACITY = 0.15;

// Render ordering
const NODE_RENDER_ORDER = 3;

/** Disposes all geometries and materials of a THREE.Group's children. */
export function disposeGroupChildren(group) {
  for (const child of group.children) {
    child.geometry?.dispose();
    if (child.material) {
      child.material.map?.dispose();
      child.material.dispose();
    }
  }
}

export { IMPULSE_COLOR };

/** Creates point-sprite markers for all nodes with size scaled by connection count. */
export function buildNodeMarkers({
  nodes,
  nodeStyleMap,
  darkMode,
  globeGroup,
  renderer,
  nodeLabelsGroup,
}) {
  if (nodes.length === 0) return null;

  const positions = [];
  const nodeColors = [];
  const sizes = [];

  let maxConnections = 1;
  for (const n of nodes) {
    maxConnections = Math.max(maxConnections, n.connections.size);
  }

  // Scale nodes larger when there are fewer — improves visibility for small graphs
  const countScale = Math.min(MAX_COUNT_SCALE, 1 + COUNT_SCALE_DIVISOR / Math.max(nodes.length, 1));

  for (const node of nodes) {
    const pos = node.position || { x: 0, y: 0, z: 0 };
    positions.push(pos.x, pos.y, pos.z);

    const typeKey = (node.type || 'default').toLowerCase();
    const schemaStyle = nodeStyleMap[typeKey];
    const colorHex = schemaStyle?.color || getNodeColor(node);
    const color = new THREE.Color(colorHex);
    nodeColors.push(color.r, color.g, color.b);

    const rawSize = schemaStyle?.size || NODE_BASE_SIZE;
    const baseSize = rawSize * NODE_SIZE_SCALE * countScale;
    const ratio = node.connections.size / maxConnections;
    const size = baseSize + ratio * CONNECTION_SIZE_BOOST;
    sizes.push(size);
    node.baseSize = size;
  }

  const originalNodeColors = new Float32Array(nodeColors);
  const originalNodeSizes = new Float32Array(sizes);

  const nodeGeometry = new THREE.BufferGeometry();
  nodeGeometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
  nodeGeometry.setAttribute('color', new THREE.Float32BufferAttribute(nodeColors, 3));
  nodeGeometry.setAttribute('size', new THREE.Float32BufferAttribute(sizes, 1));

  const nodeMaterial = new THREE.ShaderMaterial({
    uniforms: { pixelRatio: { value: renderer.getPixelRatio() } },
    vertexShader: NODE_VERTEX_SHADER,
    fragmentShader: NODE_FRAGMENT_SHADER,
    transparent: false,
    depthTest: true,
    depthWrite: false,
  });

  const nodeMarkers = new THREE.Points(nodeGeometry, nodeMaterial);
  nodeMarkers.renderOrder = NODE_RENDER_ORDER;
  globeGroup.add(nodeMarkers);

  disposeGroupChildren(nodeLabelsGroup);
  nodeLabelsGroup.clear();
  const labelScale = countScale;
  const labelOffset = NODE_LABEL_OFFSET * (1 + (countScale - 1) * LABEL_OFFSET_SCALE_FACTOR);
  let labelIdx = 0;
  for (const node of nodes) {
    if (!node.label || !node.position) {
      node.labelIndex = -1;
    } else {
      node.labelIndex = labelIdx;
      labelIdx += 1;
      const sprite = createNodeLabelSprite(node.label, darkMode, labelScale);
      sprite.position.set(node.position.x, node.position.y - labelOffset, node.position.z);
      nodeLabelsGroup.add(sprite);
    }
  }

  return { nodeGeometry, nodeMaterial, nodeMarkers, originalNodeColors, originalNodeSizes };
}

/** Fades nodes, edges, and labels by BFS distance from the selected node. */
export function highlightSubgraph({
  nodeIndex,
  adjacencyMap,
  nodes,
  nodeGeometry,
  originalNodeColors,
  nodeLabelsGroup,
  connections,
  impulses,
  darkMode,
}) {
  if (!adjacencyMap || !nodeGeometry) return;

  const distances = runBFS(nodeIndex, adjacencyMap);
  const colorAttr = nodeGeometry.getAttribute('color');

  // Fade nodes by BFS distance
  for (let i = 0; i < nodes.length; i += 1) {
    const baseIdx = i * 3;
    if (distances.has(i)) {
      const dist = distances.get(i);
      const opacity = Math.max(BFS_MIN_OPACITY, 1.0 - dist * BFS_OPACITY_DECAY);
      colorAttr.setXYZ(
        i,
        originalNodeColors[baseIdx] * opacity,
        originalNodeColors[baseIdx + 1] * opacity,
        originalNodeColors[baseIdx + 2] * opacity,
      );
    } else if (darkMode) {
      colorAttr.setXYZ(i, 0, 0, 0);
    } else {
      colorAttr.setXYZ(
        i,
        originalNodeColors[baseIdx] * LIGHT_MODE_COLOR_MIX +
          LIGHT_MODE_FADE * (1 - LIGHT_MODE_COLOR_MIX),
        originalNodeColors[baseIdx + 1] * LIGHT_MODE_COLOR_MIX +
          LIGHT_MODE_FADE * (1 - LIGHT_MODE_COLOR_MIX),
        originalNodeColors[baseIdx + 2] * LIGHT_MODE_COLOR_MIX +
          LIGHT_MODE_FADE * (1 - LIGHT_MODE_COLOR_MIX),
      );
    }
  }
  colorAttr.needsUpdate = true;

  // Fade node labels
  for (let i = 0; i < nodes.length; i += 1) {
    const labelSprite =
      nodes[i].labelIndex >= 0 ? nodeLabelsGroup.children[nodes[i].labelIndex] : null;
    if (labelSprite) {
      if (distances.has(i)) {
        const dist = distances.get(i);
        labelSprite.material.opacity = Math.max(BFS_MIN_OPACITY, 1.0 - dist * BFS_OPACITY_DECAY);
      } else {
        labelSprite.material.opacity = darkMode ? 0 : DISCONNECTED_LABEL_OPACITY;
      }
    }
  }

  // Fade edge connections and impulses
  for (const conn of connections) {
    const dA = distances.get(conn.source);
    const dB = distances.get(conn.target);
    if (dA === undefined || dB === undefined) {
      conn.line.material.opacity = darkMode ? 0 : DISCONNECTED_EDGE_OPACITY;
      if (conn.label) conn.label.visible = false;
    } else {
      const edgeDist = Math.max(dA, dB);
      conn.line.material.opacity =
        Math.max(BFS_MIN_OPACITY, 1.0 - edgeDist * BFS_OPACITY_DECAY) * BFS_EDGE_OPACITY_SCALE;
      if (conn.label) {
        const directlyConnected = dA === 0 || dB === 0;
        conn.label.visible = directlyConnected;
        conn.label.material.opacity = directlyConnected ? 1 : 0;
      }
    }
  }

  for (const imp of impulses) {
    const dA = distances.get(imp.connection.source);
    const dB = distances.get(imp.connection.target);
    if (dA === undefined || dB === undefined) {
      imp.mesh.material.uniforms.color.value.setRGB(0, 0, 0);
    } else {
      const edgeDist = Math.max(dA, dB);
      const opacity = Math.max(BFS_MIN_OPACITY, 1.0 - edgeDist * BFS_OPACITY_DECAY);
      imp.mesh.material.uniforms.color.value.setRGB(
        IMPULSE_COLOR.r * opacity,
        IMPULSE_COLOR.g * opacity,
        IMPULSE_COLOR.b * opacity,
      );
    }
  }
}

/** Restores all nodes, edges, and labels to their default (unhighlighted) appearance. */
export function resetHighlighting({
  nodes,
  nodeGeometry,
  originalNodeColors,
  connections,
  nodeLabelsGroup,
  impulses,
}) {
  if (!nodeGeometry || !originalNodeColors) return;

  const colorAttr = nodeGeometry.getAttribute('color');
  for (let i = 0; i < nodes.length; i += 1) {
    const baseIdx = i * 3;
    colorAttr.setXYZ(
      i,
      originalNodeColors[baseIdx],
      originalNodeColors[baseIdx + 1],
      originalNodeColors[baseIdx + 2],
    );
  }
  colorAttr.needsUpdate = true;

  for (const nodeLabel of nodeLabelsGroup.children) {
    nodeLabel.material.opacity = 1;
  }

  for (const conn of connections) {
    conn.line.material.opacity = EDGE_OPACITY;
    if (conn.label) {
      conn.label.visible = false;
      conn.label.material.opacity = 1;
    }
  }

  for (const imp of impulses) {
    imp.mesh.material.uniforms.color.value.copy(IMPULSE_COLOR);
  }
}
