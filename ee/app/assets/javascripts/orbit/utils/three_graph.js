import * as THREE from 'three';
import { GRAPH_DEFAULTS } from '../constants';
import {
  computeSphereLayout,
  computeFlatLayout,
  buildAdjacencyMap,
  easeInOutSine,
} from './graph_layout';
import { clearLabelCache } from './three_labels';
import GraphScene, { CAMERA_DEFAULT_Z } from './three_scene';
import { createGlobe, createCityLights } from './three_globe';
import {
  buildNodeMarkers,
  highlightSubgraph,
  resetHighlighting,
  NODE_LABEL_OFFSET,
} from './three_nodes';
import { buildConnections } from './three_edges';
import GraphInteraction from './three_interaction';

const { GLOBE_RADIUS, NODE_HEIGHT, IDLE_TIMEOUT_MS, AUTO_ROTATE_SPEED, ANIMATION_SPEED } =
  GRAPH_DEFAULTS;

// Render layer ordering
const CONNECTIONS_RENDER_ORDER = 1;
const IMPULSES_RENDER_ORDER = 2;
const EDGE_LABELS_RENDER_ORDER = 4;
const NODE_LABELS_RENDER_ORDER = 5;

// Camera animation
const CAMERA_ANIM_DURATION_MS = 800;
const CAMERA_2D_ZOOM_FACTOR = 0.55;
const CAMERA_2D_MIN_FIT_FACTOR = 0.4;
const CAMERA_2D_FIT_PADDING = 1;

// Node expansion spread
const EXPANSION_SPREAD_BASE = 0.35;
const EXPANSION_SPREAD_VARIANCE = 0.2;
const EXPANSION_FLAT_SPREAD_MULTIPLIER = 3;
const TANGENT_VECTOR_THRESHOLD = 0.1;

/**
 * Orchestrates the 3D/2D graph visualization: scene lifecycle, node layout,
 * selection/highlighting, camera animation, and user interaction callbacks.
 */
export default class ThreeGraph {
  constructor(container, options = {}) {
    this.container = container;
    this.nodeStyleMap = options.nodeStyleMap || {};
    this.darkMode = options.darkMode !== false;
    this.nodes = [];
    this.edges = [];
    this.adjacencyMap = null;
    this.connections = [];
    this.impulses = [];
    this.selectedNode = null;
    this.animationId = null;
    this.animationSpeed = ANIMATION_SPEED;
    this.viewMode = '3d';

    this.originalNodeColors = null;
    this.originalNodeSizes = null;
    this.nodeGeometry = null;
    this.nodeMaterial = null;
    this.nodeMarkers = null;

    this.graphScene = new GraphScene(container);
    this.interaction = null;

    this.pendingCallbacks = { hover: null, select: null, expand: null };
  }

  /** Creates the scene, camera, controls, globe, and wires up interaction handlers. */
  init() {
    this.graphScene.init();

    this.scene = this.graphScene.scene;
    this.camera = this.graphScene.camera;
    this.renderer = this.graphScene.renderer;
    this.controls = this.graphScene.controls;

    this.globeGroup = new THREE.Group();
    this.scene.add(this.globeGroup);

    createGlobe(this.globeGroup, this.darkMode);
    createCityLights(this.globeGroup, this.renderer, this.darkMode);

    this.connectionsGroup = new THREE.Group();
    this.connectionsGroup.renderOrder = CONNECTIONS_RENDER_ORDER;
    this.impulsesGroup = new THREE.Group();
    this.impulsesGroup.renderOrder = IMPULSES_RENDER_ORDER;
    this.labelsGroup = new THREE.Group();
    this.labelsGroup.renderOrder = EDGE_LABELS_RENDER_ORDER;
    this.nodeLabelsGroup = new THREE.Group();
    this.nodeLabelsGroup.renderOrder = NODE_LABELS_RENDER_ORDER;
    this.globeGroup.add(this.connectionsGroup);
    this.globeGroup.add(this.impulsesGroup);
    this.globeGroup.add(this.labelsGroup);
    this.globeGroup.add(this.nodeLabelsGroup);

    this.interaction = new GraphInteraction({
      renderer: this.renderer,
      camera: this.camera,
      controls: this.controls,
      globeGroup: this.globeGroup,
    });
    this.interaction.setContext({
      nodes: this.nodes,
      nodeGeometry: this.nodeGeometry,
      originalNodeSizes: this.originalNodeSizes,
      nodeLabelsGroup: this.nodeLabelsGroup,
      connections: this.connections,
      selectNode: (idx) => this.selectNode(idx),
      deselectNode: () => this.deselectNode(),
    });
    this.interaction.attach();

    if (this.pendingCallbacks.hover) this.interaction.onNodeHover(this.pendingCallbacks.hover);
    if (this.pendingCallbacks.select) this.interaction.onNodeSelect(this.pendingCallbacks.select);
    if (this.pendingCallbacks.expand) this.interaction.onNodeExpand(this.pendingCallbacks.expand);

    this.runAnimation();
  }

  /** Tears down the scene, cancels animations, and releases GPU resources. */
  dispose() {
    if (this.animationId) {
      cancelAnimationFrame(this.animationId);
      this.animationId = null;
    }
    if (this.cameraAnimationId) {
      cancelAnimationFrame(this.cameraAnimationId);
      this.cameraAnimationId = null;
    }

    if (this.interaction) {
      this.interaction.detach();
    }

    this.graphScene.dispose();
    clearLabelCache();
  }

  syncInteractionContext() {
    if (!this.interaction) return;
    this.interaction.setContext({
      nodes: this.nodes,
      nodeGeometry: this.nodeGeometry,
      originalNodeSizes: this.originalNodeSizes,
      nodeLabelsGroup: this.nodeLabelsGroup,
      connections: this.connections,
      selectNode: (idx) => this.selectNode(idx),
      deselectNode: () => this.deselectNode(),
    });
  }

  updateConnectionSets(edges) {
    for (const e of edges) {
      if (this.nodes[e.source] && this.nodes[e.target]) {
        this.nodes[e.source].connections.add(e.target);
        this.nodes[e.target].connections.add(e.source);
      }
    }
  }

  /** Sets the full node/edge dataset, runs layout, and rebuilds all visual geometry. */
  setData(nodes, edges) {
    this.nodes = nodes.map((n, i) => ({ ...n, index: i, connections: new Set() }));
    this.edges = edges;

    this.updateConnectionSets(edges);
    this.adjacencyMap = buildAdjacencyMap(this.nodes, edges);

    if (this.viewMode === '3d') {
      computeSphereLayout(this.nodes, edges);
    } else {
      computeFlatLayout(this.nodes, edges);
    }

    this.buildNodeMarkers();
    this.buildConnections();

    this.selectedNode = null;
    if (this.interaction) this.interaction.hoveredNode = null;
  }

  resolveParentPosition(newEdges) {
    const parentIdx = newEdges.length > 0 ? newEdges[0].source : null;
    const parentNode = parentIdx !== null ? this.nodes[parentIdx] : null;
    return parentNode?.position
      ? new THREE.Vector3(parentNode.position.x, parentNode.position.y, parentNode.position.z)
      : new THREE.Vector3(0, 0, GLOBE_RADIUS * NODE_HEIGHT);
  }

  computeExpansionPosition(parentPos, angle, spread) {
    if (this.viewMode === '2d') {
      const flatSpread = spread * EXPANSION_FLAT_SPREAD_MULTIPLIER;
      return new THREE.Vector3(
        parentPos.x + Math.cos(angle) * flatSpread,
        parentPos.y + Math.sin(angle) * flatSpread,
        0,
      );
    }

    const dir = parentPos.clone().normalize();
    const up = new THREE.Vector3(0, 1, 0);
    let t1 = new THREE.Vector3().crossVectors(dir, up).normalize();
    if (t1.length() < TANGENT_VECTOR_THRESHOLD) {
      t1 = new THREE.Vector3().crossVectors(dir, new THREE.Vector3(1, 0, 0)).normalize();
    }
    const t2 = new THREE.Vector3().crossVectors(dir, t1).normalize();

    return dir
      .clone()
      .add(t1.clone().multiplyScalar(Math.cos(angle) * spread))
      .add(t2.clone().multiplyScalar(Math.sin(angle) * spread))
      .normalize()
      .multiplyScalar(GLOBE_RADIUS * NODE_HEIGHT);
  }

  /** Appends expanded nodes and edges around a parent, rebuilds geometry incrementally. */
  addData(newNodes, newEdges) {
    const startIdx = this.nodes.length;
    const parentPos = this.resolveParentPosition(newEdges);

    const addedNodes = newNodes.map((n, i) => {
      const angle = (i / newNodes.length) * Math.PI * 2;
      const spread = EXPANSION_SPREAD_BASE + Math.random() * EXPANSION_SPREAD_VARIANCE;
      const pos = this.computeExpansionPosition(parentPos, angle, spread);

      return {
        ...n,
        index: startIdx + i,
        connections: new Set(),
        position: { x: pos.x, y: pos.y, z: pos.z },
      };
    });

    this.nodes = this.nodes.concat(addedNodes);
    this.edges = this.edges.concat(newEdges);

    this.updateConnectionSets(newEdges);
    this.adjacencyMap = buildAdjacencyMap(this.nodes, this.edges);
    this.buildNodeMarkers();
    this.buildConnections();
  }

  buildNodeMarkers() {
    if (this.nodeMarkers) {
      this.globeGroup.remove(this.nodeMarkers);
      this.nodeGeometry?.dispose();
      this.nodeMaterial?.dispose();
    }

    if (this.nodes.length === 0) return;

    const result = buildNodeMarkers({
      nodes: this.nodes,
      nodeStyleMap: this.nodeStyleMap,
      darkMode: this.darkMode,
      globeGroup: this.globeGroup,
      renderer: this.renderer,
      nodeLabelsGroup: this.nodeLabelsGroup,
      flat: this.viewMode === '2d',
    });

    if (result) {
      this.nodeGeometry = result.nodeGeometry;
      this.nodeMaterial = result.nodeMaterial;
      this.nodeMarkers = result.nodeMarkers;
      this.originalNodeColors = result.originalNodeColors;
      this.originalNodeSizes = result.originalNodeSizes;
      this.syncInteractionContext();
    }
  }

  buildConnections() {
    const result = buildConnections({
      edges: this.edges,
      nodes: this.nodes,
      darkMode: this.darkMode,
      renderer: this.renderer,
      connectionsGroup: this.connectionsGroup,
      impulsesGroup: this.impulsesGroup,
      labelsGroup: this.labelsGroup,
      flat: this.viewMode === '2d',
    });
    this.connections = result.connections;
    this.impulses = result.impulses;
    this.syncInteractionContext();
  }

  /** Selects a node by index, highlights its subgraph, and navigates the camera. */
  selectNode(nodeIndex) {
    if (nodeIndex === null || nodeIndex === undefined) {
      this.deselectNode();
      return;
    }

    const node = this.nodes[nodeIndex];
    if (!node) return;

    this.selectedNode = node;
    this.highlightSubgraph(nodeIndex);
    if (this.viewMode === '3d') {
      this.navigateToNode(nodeIndex);
    }

    if (this.interaction?.onNodeSelectCallback) {
      this.interaction.onNodeSelectCallback(node);
    }
  }

  /** Clears the current selection and restores default highlighting. */
  deselectNode() {
    this.selectedNode = null;
    this.resetHighlighting();

    if (this.interaction?.onNodeSelectCallback) {
      this.interaction.onNodeSelectCallback(null);
    }
  }

  /** Animates the camera to focus on the node at the given index. */
  navigateToNode(nodeIndex) {
    const node = this.nodes[nodeIndex];
    if (!node || !node.position) return;

    if (this.viewMode === '2d') {
      const z = CAMERA_DEFAULT_Z * CAMERA_2D_ZOOM_FACTOR;
      const target = new THREE.Vector3(node.position.x, node.position.y, z);
      this.graphScene.controls.target.set(node.position.x, node.position.y, 0);
      this.animateCamera(target);
    } else {
      const pos = new THREE.Vector3(node.position.x, node.position.y, node.position.z);
      const target = pos.clone().normalize().multiplyScalar(CAMERA_DEFAULT_Z);
      this.animateCamera(target);
    }
  }

  resetInteractionState() {
    this.selectedNode = null;
    if (this.interaction) this.interaction.hoveredNode = null;
  }

  setGlobeVisibility(mode) {
    if (mode === '3d') {
      for (const c of this.globeGroup.children) {
        c.visible = true;
      }
    } else {
      for (const c of this.globeGroup.children) {
        if (
          c !== this.connectionsGroup &&
          c !== this.impulsesGroup &&
          c !== this.nodeMarkers &&
          c !== this.labelsGroup &&
          c !== this.nodeLabelsGroup
        ) {
          c.visible = false;
        }
      }
    }
  }

  computeFitCameraZ() {
    let maxExtent = 0;
    for (const n of this.nodes) {
      if (n.position) {
        maxExtent = Math.max(maxExtent, Math.abs(n.position.x), Math.abs(n.position.y));
      }
    }
    const fovRad = (this.camera.fov / 2) * (Math.PI / 180);
    return Math.max(
      maxExtent / Math.tan(fovRad) + CAMERA_2D_FIT_PADDING,
      CAMERA_DEFAULT_Z * CAMERA_2D_MIN_FIT_FACTOR,
    );
  }

  /** Switches between '2d' and '3d' view modes with a full layout and camera reset. */
  setViewMode(mode) {
    this.viewMode = mode;
    if (this.interaction) this.interaction.viewMode = mode;

    this.resetInteractionState();

    if (mode === '2d') {
      this.graphScene.setMode2D();
    } else {
      this.graphScene.setMode3D();
    }

    if (this.nodes.length === 0) return;

    this.globeGroup.rotation.set(0, 0, 0);

    if (mode === '3d') {
      computeSphereLayout(this.nodes, this.edges);
    } else {
      computeFlatLayout(this.nodes, this.edges);
    }

    this.setGlobeVisibility(mode);
    this.buildNodeMarkers();
    this.buildConnections();

    this.graphScene.controls.target.set(0, 0, 0);
    if (mode === '3d') {
      this.animateCamera(new THREE.Vector3(0, 0, CAMERA_DEFAULT_Z));
    } else {
      this.animateCamera(new THREE.Vector3(0, 0, this.computeFitCameraZ()));
    }
  }

  resize(width, height) {
    this.graphScene.resize(width, height);
  }

  /** Returns nodes matching the query string against label, type, or id. */
  searchNodes(query) {
    if (!query || query.length < 2) return [];
    const q = query.toLowerCase();
    return this.nodes.filter(
      (n) =>
        (n.label && n.label.toLowerCase().includes(q)) ||
        (n.type && n.type.toLowerCase().includes(q)) ||
        (n.id && String(n.id).toLowerCase().includes(q)),
    );
  }

  /** Registers a callback invoked when a node is hovered. */
  onNodeHover(callback) {
    this.pendingCallbacks.hover = callback;
    if (this.interaction) this.interaction.onNodeHover(callback);
  }

  /** Registers a callback invoked when a node is selected. */
  onNodeSelect(callback) {
    this.pendingCallbacks.select = callback;
    if (this.interaction) this.interaction.onNodeSelect(callback);
  }

  /** Registers a callback invoked when a node is double-clicked for expansion. */
  onNodeExpand(callback) {
    this.pendingCallbacks.expand = callback;
    if (this.interaction) this.interaction.onNodeExpand(callback);
  }

  highlightSubgraph(nodeIndex) {
    highlightSubgraph({
      nodeIndex,
      adjacencyMap: this.adjacencyMap,
      nodes: this.nodes,
      nodeGeometry: this.nodeGeometry,
      originalNodeColors: this.originalNodeColors,
      originalNodeSizes: this.originalNodeSizes,
      nodeLabelsGroup: this.nodeLabelsGroup,
      connections: this.connections,
      impulses: this.impulses,
      darkMode: this.darkMode,
    });
  }

  resetHighlighting() {
    resetHighlighting({
      nodes: this.nodes,
      nodeGeometry: this.nodeGeometry,
      originalNodeColors: this.originalNodeColors,
      connections: this.connections,
      nodeLabelsGroup: this.nodeLabelsGroup,
      impulses: this.impulses,
    });
  }

  animateCamera(targetPos) {
    if (this.cameraAnimationId) {
      cancelAnimationFrame(this.cameraAnimationId);
      this.cameraAnimationId = null;
    }

    const startPos = this.camera.position.clone();
    const startTime = Date.now();
    const duration = CAMERA_ANIM_DURATION_MS;

    const animate = () => {
      const elapsed = Date.now() - startTime;
      const t = Math.min(elapsed / duration, 1);
      const eased = easeInOutSine(t);
      this.camera.position.lerpVectors(startPos, targetPos, eased);
      this.camera.lookAt(this.graphScene.controls.target);
      this.controls.update();

      if (t < 1) {
        this.cameraAnimationId = requestAnimationFrame(animate);
      } else {
        this.cameraAnimationId = null;
      }
    };
    animate();
  }

  tickImpulses() {
    for (const impulse of this.impulses) {
      impulse.linearProgress += impulse.baseSpeed * impulse.direction * this.animationSpeed;

      if (impulse.linearProgress > 1) impulse.linearProgress = 0;
      else if (impulse.linearProgress < 0) impulse.linearProgress = 1;

      const easedProgress = easeInOutSine(impulse.linearProgress);
      const point = impulse.connection.curve.getPoint(easedProgress);
      impulse.mesh.position.copy(point);
    }
  }

  autoRotateGlobe() {
    const lastInteraction = this.interaction?.lastInteractionTime ?? Date.now();
    const idleTime = Date.now() - lastInteraction;
    if (idleTime > IDLE_TIMEOUT_MS && !this.selectedNode && this.viewMode === '3d') {
      this.globeGroup.rotation.y += AUTO_ROTATE_SPEED;
    }
  }

  counterScaleLabels() {
    if (this.viewMode !== '2d' || !this.nodeLabelsGroup) return;

    const camZ = this.camera.position.z;
    const refZ = CAMERA_DEFAULT_Z * CAMERA_2D_ZOOM_FACTOR;
    const factor = camZ / refZ;
    for (const label of this.nodeLabelsGroup.children) {
      if (!label.userData.baseScale) {
        label.userData.baseScale = { x: label.scale.x, y: label.scale.y };
        label.userData.nodeY = label.position.y + NODE_LABEL_OFFSET;
      }
      label.scale.set(label.userData.baseScale.x * factor, label.userData.baseScale.y * factor, 1);
      label.position.y = label.userData.nodeY - NODE_LABEL_OFFSET * factor;
    }
  }

  runAnimation() {
    this.animationId = requestAnimationFrame(() => this.runAnimation());

    this.tickImpulses();
    this.autoRotateGlobe();
    this.counterScaleLabels();

    this.controls.update();
    this.graphScene.render();
  }
}
