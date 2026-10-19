<script>
import { defineComponent, markRaw, nextTick } from 'vue';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import ThreeGraph3D from '../utils/three_graph_3d';

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
  },
  emits: ['node-select', 'node-hover', 'node-expand', 'init-error'],
  expose: ['setFullData', 'addData', 'setNodeLoading'],
  data() {
    return {
      graph: null,
      resizeObserver: null,
    };
  },
  watch: {
    selectedNodeId(id) {
      if (!this.graph) return;
      if (id == null) {
        this.graph.deselectNode();
        return;
      }
      const idx = this.nodes.findIndex((n) => n.id === id);
      if (idx >= 0) this.graph.selectNode(idx);
    },
  },
  mounted() {
    if (!this.initGraph()) return;

    this.resizeObserver = markRaw(
      new ResizeObserver((entries) => {
        const { width, height } = entries[0].contentRect;
        if (width > 0 && height > 0) {
          this.graph?.resize(width, height);
        }
      }),
    );
    this.resizeObserver.observe(this.$el);

    // Resize after the next tick so the flex layout has settled and the
    // renderer captures the final container dimensions rather than any
    // intermediate size that existed at mount time.
    nextTick(() => {
      const { offsetWidth, offsetHeight } = this.$el;
      if (offsetWidth > 0 && offsetHeight > 0) {
        this.graph?.resize(offsetWidth, offsetHeight);
      }
    });

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
        this.graph = markRaw(new ThreeGraph3D(this.$refs.canvas, options));
        this.graph.init();
        this.graph.onNodeHover((node, position) => this.$emit('node-hover', node, position));
        this.graph.onNodeSelect((node) => this.$emit('node-select', node));
        this.graph.onNodeExpand((node) => this.$emit('node-expand', node));
        return true;
      } catch (error) {
        // init() throws without WebGL, and a half-built graph cannot dispose.
        this.graph = null;
        Sentry.captureException(error);
        this.$emit('init-error', error);
        return false;
      }
    },

    setFullData() {
      this.graph.setData(this.nodes, this.edges);
    },

    addData(newNodes, newEdges) {
      this.graph.addData(newNodes, newEdges);
      // addData() places new nodes in a ring around their parent; relayout() spreads
      // them over the Fibonacci spiral.
      this.graph.relayout();
    },

    setNodeLoading(nodeIndex, loading) {
      this.graph.setNodeLoading(nodeIndex, loading);
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
