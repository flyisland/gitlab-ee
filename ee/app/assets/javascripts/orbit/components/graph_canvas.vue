<script>
import { defineComponent, markRaw } from 'vue';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import ThreeGraph2D from '../utils/three_graph_2d';
import ThreeGraph3D from '../utils/three_graph_3d';

const MAP_MODE_2D = '2d';
const MAP_MODE_3D = '3d';
const ZOOM_IN_FACTOR = 0.8;
const ZOOM_OUT_FACTOR = 1.25;

export default defineComponent({
  name: 'GraphCanvas',
  compatConfig: { MODE: 3 },
  props: {
    nodes: {
      type: Array,
      required: true,
    },
    edges: {
      type: Array,
      required: true,
    },
    selectedNodeId: {
      type: String,
      required: false,
      default: null,
    },
    nodeStyleMap: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    darkMode: {
      type: Boolean,
      required: false,
      default: true,
    },
    mapMode: {
      type: String,
      required: false,
      default: MAP_MODE_3D,
      validator: (v) => v === MAP_MODE_2D || v === MAP_MODE_3D,
    },
  },
  emits: ['node-select', 'node-hover', 'node-expand', 'init-error'],
  expose: ['setFullData', 'addData', 'searchNodes', 'zoomIn', 'zoomOut', 'highlightByTypes'],
  data() {
    return {
      graph: null,
      resizeObserver: null,
    };
  },
  watch: {
    selectedNodeId(id) {
      if (id == null) {
        this.graph.deselectNode();
        return;
      }
      const idx = this.nodes.findIndex((n) => n.id === id);
      if (idx >= 0) this.graph.selectNode(idx);
    },
    mapMode() {
      this.rebuildGraph();
    },
  },
  mounted() {
    if (!this.initGraph()) return;

    this.resizeObserver = markRaw(
      new ResizeObserver((entries) => {
        const { width, height } = entries[0].contentRect;
        if (width > 0 && height > 0) {
          this.graph.resize(width, height);
        }
      }),
    );
    this.resizeObserver.observe(this.$el);

    if (this.nodes.length > 0) {
      this.graph.setData(this.nodes, this.edges);
    }
  },
  beforeUnmount() {
    this.cleanupCanvas();
  },
  // Vue 2 + compat MODE 3 fires beforeDestroy on $destroy, not beforeUnmount.
  // Aliased so spec wrapper.destroy() exercises the same cleanup path.
  beforeDestroy() {
    this.cleanupCanvas();
  },
  methods: {
    cleanupCanvas() {
      if (this.resizeObserver) {
        this.resizeObserver.disconnect();
        this.resizeObserver = null;
      }
      if (this.graph) {
        this.graph.dispose();
        this.graph = null;
      }
    },
    initGraph() {
      try {
        const options = { nodeStyleMap: this.nodeStyleMap, darkMode: this.darkMode };
        const GraphClass = this.mapMode === MAP_MODE_2D ? ThreeGraph2D : ThreeGraph3D;
        this.graph = markRaw(new GraphClass(this.$refs.canvas, options));
        this.graph.init();
        this.graph.onNodeHover((node, position) => this.$emit('node-hover', node, position));
        this.graph.onNodeSelect((node) => this.$emit('node-select', node));
        this.graph.onNodeExpand((node) => this.$emit('node-expand', node));
        return true;
      } catch (error) {
        Sentry.captureException(error);
        this.$emit('init-error', error);
        return false;
      }
    },

    rebuildGraph() {
      if (this.graph) this.graph.dispose();
      this.graph = null;
      if (!this.initGraph()) return;
      if (this.nodes.length > 0) {
        this.graph.setData(this.nodes, this.edges);
      }
    },

    setFullData() {
      this.graph.setData(this.nodes, this.edges);
    },

    addData(newNodes, newEdges) {
      this.graph.addData(newNodes, newEdges);
    },

    searchNodes(query) {
      return this.graph.searchNodes(query);
    },

    zoomIn() {
      this.graph.zoomBy(ZOOM_IN_FACTOR);
    },

    zoomOut() {
      this.graph.zoomBy(ZOOM_OUT_FACTOR);
    },

    highlightByTypes(activeTypes) {
      this.graph.highlightByTypes(activeTypes);
    },
  },
});
</script>

<template>
  <div class="gl-relative gl-h-full gl-w-full" data-testid="graph-canvas">
    <div
      v-show="graph"
      ref="canvas"
      class="gl-h-full gl-w-full gl-cursor-grab"
      data-testid="graph-canvas-3d"
    ></div>
  </div>
</template>
