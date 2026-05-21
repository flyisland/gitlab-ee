import * as THREE from 'three';
import { GRAPH_DEFAULTS } from '../constants';
import { computeFlatLayout, buildAdjacencyMap, easeInOutSine } from './graph_layout';
import { clearLabelCache } from './three_labels';
import GraphScene, { CAMERA_DEFAULT_Z } from './three_scene';
import {
  buildNodeMarkers,
  highlightSubgraph,
  highlightByTypes,
  resetHighlighting,
  NODE_LABEL_OFFSET,
} from './three_nodes';
import { buildFlatConnections } from './three_edges_2d';
import GraphInteraction2D from './three_interaction_2d';

const { ANIMATION_SPEED, MIN_ZOOM_DISTANCE, MIN_SEARCH_LENGTH } = GRAPH_DEFAULTS;

const CONNECTIONS_RENDER_ORDER = 1;
const IMPULSES_RENDER_ORDER = 2;
const EDGE_LABELS_RENDER_ORDER = 4;
const NODE_LABELS_RENDER_ORDER = 5;

const CAMERA_ANIM_DURATION_MS = 800;
const CAMERA_2D_ZOOM_FACTOR = 0.55;
const CAMERA_2D_MIN_FIT_FACTOR = 0.4;
const CAMERA_2D_FIT_PADDING = 1;

const EXPANSION_SPREAD_BASE = 0.35;
const EXPANSION_SPREAD_VARIANCE = 0.2;
const EXPANSION_FLAT_SPREAD_MULTIPLIER = 3;

export default class ThreeGraph2D {
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
    this.cameraAnimationId = null;
    this.animationSpeed = ANIMATION_SPEED;
    this.active = true;

    this.originalNodeColors = null;
    this.originalNodeSizes = null;
    this.nodeGeometry = null;
    this.nodeMaterial = null;
    this.nodeMarkers = null;

    this.graphScene = new GraphScene(container);
    this.interaction = null;
    this.pendingCallbacks = { hover: null, select: null, expand: null };
  }

  init() {
    this.graphScene.init();
    this.graphScene.setMode2D();

    this.scene = this.graphScene.scene;
    this.camera = this.graphScene.camera;
    this.renderer = this.graphScene.renderer;
    this.controls = this.graphScene.controls;

    // Parent group for all graph objects (analogous to globeGroup in 3D,
    // keeps coordinate transform path identical for interaction code)
    this.graphGroup = new THREE.Group();
    this.scene.add(this.graphGroup);

    this.connectionsGroup = new THREE.Group();
    this.connectionsGroup.renderOrder = CONNECTIONS_RENDER_ORDER;
    this.impulsesGroup = new THREE.Group();
    this.impulsesGroup.renderOrder = IMPULSES_RENDER_ORDER;
    this.labelsGroup = new THREE.Group();
    this.labelsGroup.renderOrder = EDGE_LABELS_RENDER_ORDER;
    this.nodeLabelsGroup = new THREE.Group();
    this.nodeLabelsGroup.renderOrder = NODE_LABELS_RENDER_ORDER;
    this.graphGroup.add(this.connectionsGroup);
    this.graphGroup.add(this.impulsesGroup);
    this.graphGroup.add(this.labelsGroup);
    this.graphGroup.add(this.nodeLabelsGroup);

    this.interaction = new GraphInteraction2D({
      renderer: this.renderer,
      camera: this.camera,
      controls: this.controls,
      globeGroup: this.graphGroup,
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

  dispose() {
    this.active = false;
    if (this.animationId) {
      cancelAnimationFrame(this.animationId);
      this.animationId = null;
    }
    if (this.cameraAnimationId) {
      cancelAnimationFrame(this.cameraAnimationId);
      this.cameraAnimationId = null;
    }
    if (this.interaction) this.interaction.detach();
    this.graphScene.dispose();
    clearLabelCache();
  }

  pause() {
    this.active = false;
    if (this.animationId) {
      cancelAnimationFrame(this.animationId);
      this.animationId = null;
    }
  }

  resume() {
    if (this.active) return;
    this.active = true;
    this.runAnimation();
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

  setData(nodes, edges) {
    this.nodes = nodes.map((n, i) => ({ ...n, index: i, connections: new Set() }));
    this.edges = edges;

    this.updateConnectionSets(edges);
    this.adjacencyMap = buildAdjacencyMap(this.nodes, edges);

    computeFlatLayout(this.nodes, edges);

    this.buildNodeMarkers();
    this.buildConnections();

    this.camera.position.set(0, 0, this.computeFitCameraZ());
    this.controls.target.set(0, 0, 0);
    this.camera.lookAt(0, 0, 0);
    this.controls.update();

    this.selectedNode = null;
    if (this.interaction) this.interaction.hoveredNode = null;
  }

  addData(newNodes, newEdges) {
    const startIdx = this.nodes.length;
    const parentIdx = newEdges.length > 0 ? newEdges[0].source : null;
    const parentNode = parentIdx !== null ? this.nodes[parentIdx] : null;
    const parentPos = parentNode?.position
      ? new THREE.Vector3(parentNode.position.x, parentNode.position.y, parentNode.position.z)
      : new THREE.Vector3(0, 0, 0);

    const addedNodes = newNodes.map((n, i) => {
      const angle = (i / newNodes.length) * Math.PI * 2;
      const spread =
        (EXPANSION_SPREAD_BASE + Math.random() * EXPANSION_SPREAD_VARIANCE) *
        EXPANSION_FLAT_SPREAD_MULTIPLIER;

      return {
        ...n,
        index: startIdx + i,
        connections: new Set(),
        position: {
          x: parentPos.x + Math.cos(angle) * spread,
          y: parentPos.y + Math.sin(angle) * spread,
          z: 0,
        },
      };
    });

    this.nodes = this.nodes.concat(addedNodes);
    this.edges = this.edges.concat(newEdges);

    this.updateConnectionSets(newEdges);
    this.adjacencyMap = buildAdjacencyMap(this.nodes, this.edges);

    computeFlatLayout(this.nodes, this.edges);

    this.buildNodeMarkers();
    this.buildConnections();

    this.controls.target.set(0, 0, 0);
    this.camera.position.set(0, 0, this.computeFitCameraZ());
    this.camera.lookAt(0, 0, 0);
    this.controls.update();
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

  buildNodeMarkers() {
    if (this.nodeMarkers) {
      this.graphGroup.remove(this.nodeMarkers);
      this.nodeGeometry?.dispose();
      this.nodeMaterial?.dispose();
    }

    if (this.nodes.length === 0) return;

    const result = buildNodeMarkers({
      nodes: this.nodes,
      nodeStyleMap: this.nodeStyleMap,
      darkMode: this.darkMode,
      globeGroup: this.graphGroup,
      renderer: this.renderer,
      nodeLabelsGroup: this.nodeLabelsGroup,
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
    const result = buildFlatConnections({
      edges: this.edges,
      nodes: this.nodes,
      darkMode: this.darkMode,
      renderer: this.renderer,
      connectionsGroup: this.connectionsGroup,
      impulsesGroup: this.impulsesGroup,
      labelsGroup: this.labelsGroup,
    });
    this.connections = result.connections;
    this.impulses = result.impulses;
    this.syncInteractionContext();
  }

  selectNode(nodeIndex) {
    if (nodeIndex === null || nodeIndex === undefined) {
      this.deselectNode();
      return;
    }

    const node = this.nodes[nodeIndex];
    if (!node) return;

    this.selectedNode = node;
    this.highlightSubgraph(nodeIndex);

    if (this.interaction?.onNodeSelectCallback) {
      this.interaction.onNodeSelectCallback(node);
    }
  }

  deselectNode() {
    this.selectedNode = null;
    this.resetHighlighting();
    if (this.interaction?.onNodeSelectCallback) {
      this.interaction.onNodeSelectCallback(null);
    }
  }

  navigateToNode(nodeIndex) {
    const node = this.nodes[nodeIndex];
    if (!node?.position) return;

    const z = CAMERA_DEFAULT_Z * CAMERA_2D_ZOOM_FACTOR;
    const target = new THREE.Vector3(node.position.x, node.position.y, z);
    this.controls.target.set(node.position.x, node.position.y, 0);
    this.animateCamera(target);
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

  highlightByTypes(activeTypes) {
    highlightByTypes({
      activeTypes,
      nodes: this.nodes,
      nodeGeometry: this.nodeGeometry,
      originalNodeColors: this.originalNodeColors,
      nodeLabelsGroup: this.nodeLabelsGroup,
      connections: this.connections,
      impulses: this.impulses,
      darkMode: this.darkMode,
    });
  }

  animateCamera(targetPos) {
    if (this.cameraAnimationId) {
      cancelAnimationFrame(this.cameraAnimationId);
      this.cameraAnimationId = null;
    }

    const startPos = this.camera.position.clone();
    const startTime = Date.now();

    const animate = () => {
      const elapsed = Date.now() - startTime;
      const t = Math.min(elapsed / CAMERA_ANIM_DURATION_MS, 1);
      const eased = easeInOutSine(t);
      this.camera.position.lerpVectors(startPos, targetPos, eased);
      this.camera.lookAt(this.controls.target);
      this.controls.update();

      if (t < 1) {
        this.cameraAnimationId = requestAnimationFrame(animate);
      } else {
        this.cameraAnimationId = null;
      }
    };
    animate();
  }

  resize(width, height) {
    this.graphScene.resize(width, height);
  }

  zoomBy(factor) {
    if (!this.camera || !this.graphScene?.controls) return;
    const { controls } = this.graphScene;
    const { target } = controls;
    const offset = this.camera.position.clone().sub(target);
    const minDist = controls.minDistance ?? MIN_ZOOM_DISTANCE;
    const maxDist = controls.maxDistance ?? Infinity;
    const newLen = Math.max(minDist, Math.min(maxDist, offset.length() * factor));
    offset.setLength(newLen);
    this.camera.position.copy(target).add(offset);
    controls.update();
  }

  searchNodes(query) {
    if (!query || query.length < MIN_SEARCH_LENGTH) return [];
    const q = query.toLowerCase();
    return this.nodes.filter(
      (n) =>
        (n.label && n.label.toLowerCase().includes(q)) ||
        (n.type && n.type.toLowerCase().includes(q)) ||
        (n.id && String(n.id).toLowerCase().includes(q)),
    );
  }

  onNodeHover(callback) {
    this.pendingCallbacks.hover = callback;
    if (this.interaction) this.interaction.onNodeHover(callback);
  }

  onNodeSelect(callback) {
    this.pendingCallbacks.select = callback;
    if (this.interaction) this.interaction.onNodeSelect(callback);
  }

  onNodeExpand(callback) {
    this.pendingCallbacks.expand = callback;
    if (this.interaction) this.interaction.onNodeExpand(callback);
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

  counterScaleLabels() {
    if (!this.nodeLabelsGroup) return;

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
    if (!this.active) return;
    this.animationId = requestAnimationFrame(() => this.runAnimation());

    this.tickImpulses();
    this.counterScaleLabels();

    this.controls.update();
    this.graphScene.render();
  }
}
