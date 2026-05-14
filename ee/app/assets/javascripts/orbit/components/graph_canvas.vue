<script>
import { defineComponent, markRaw } from 'vue';
import ThreeGraph from '../utils/three_graph';

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
    viewMode: {
      type: String,
      required: false,
      default: '3d',
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
  emits: ['node-select', 'node-hover', 'node-expand'],
  expose: ['setFullData', 'addData', 'searchNodes'],
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
      if (idx < 0) return;
      this.graph.selectNode(idx);
    },
    viewMode(mode) {
      if (!this.graph) return;
      this.graph.setViewMode(mode);
    },
  },
  mounted() {
    // ThreeGraph init can fail (missing WebGL, headless env). The try/catch
    // handles this in-place rather than a parent/child split because the
    // parent already gates rendering with v-if on loading state, and a
    // split would add indirection without improving error handling.
    try {
      this.graph = markRaw(
        new ThreeGraph(this.$refs.canvas, {
          nodeStyleMap: this.nodeStyleMap,
          darkMode: this.darkMode,
        }),
      );
      this.graph.init();
    } catch {
      this.$emit('node-select', null);
      return;
    }

    this.graph.onNodeHover((node, position) => {
      this.$emit('node-hover', node, position);
    });

    this.graph.onNodeSelect((node) => {
      this.$emit('node-select', node);
    });

    this.graph.onNodeExpand((node) => {
      this.$emit('node-expand', node);
    });

    this.resizeObserver = new ResizeObserver((entries) => {
      const { width, height } = entries[0].contentRect;
      if (width > 0 && height > 0) {
        this.graph.resize(width, height);
      }
    });
    this.resizeObserver.observe(this.$refs.canvas);

    if (this.nodes.length > 0) {
      this.graph.setData(this.nodes, this.edges);
    }
  },
  beforeUnmount() {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }
    if (this.graph) {
      this.graph.dispose();
    }
  },
  methods: {
    setFullData() {
      if (this.graph) this.graph.setData(this.nodes, this.edges);
    },
    addData(newNodes, newEdges) {
      if (this.graph) this.graph.addData(newNodes, newEdges);
    },
    searchNodes(query) {
      return this.graph ? this.graph.searchNodes(query) : [];
    },
  },
});
</script>

<template>
  <div ref="canvas" class="gl-h-full gl-w-full gl-cursor-grab" data-testid="graph-canvas"></div>
</template>
