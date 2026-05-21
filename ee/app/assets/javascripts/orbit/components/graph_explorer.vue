<script>
import { defineComponent } from 'vue';
import { GlButton, GlButtonGroup, GlLoadingIcon } from '@gitlab/ui';
import { createAlert } from '~/alert';
import { darkModeEnabled } from '~/lib/utils/color_utils';
import { s__ } from '~/locale';
import { executeOrbitQuery } from '../api/orbit_api';
import {
  buildExampleQueries,
  ENTITY_TYPE_COLORS,
  ENTITY_TYPE_NAMES,
  TAB_GRAPH,
  TAB_TABLE,
} from '../constants';
import { transformGraphResponse, mergeNeighborNodes, toGraphId } from '../utils/graph_transform';
import {
  buildNodeStyleMap,
  entityColorsFromSchema,
  entityNamesFromSchema,
} from '../utils/node_style_map';
import { withCache, FIVE_MINUTES_MS } from '../utils/orbit_cache';
import GraphFilterBar from './graph_filter_bar.vue';
import GraphLegend from './graph_legend.vue';
import ExplorerNodeSidebar from './explorer_node_sidebar.vue';
import ExplorerQueryPanel from './explorer_query_panel.vue';
import ExplorerTablePanel from './explorer_table_panel.vue';
import GraphCanvas from './graph_canvas.vue';
import NodeDetailOverlay from './node_detail_overlay.vue';

// Cap on neighbor rows returned for the batched initial-group expansion.
// Capping rows keeps the first render cheap regardless of how many groups
// the user is in.
const INITIAL_NEIGHBOR_LIMIT = 500;
// GKG NodeSelector.node_ids has maxItems 500; clamp the source IDs too so
// users in 500+ groups don't hit a 4xx before the page renders.
const INITIAL_NODE_IDS_CAP = 500;
// Per-node limit when a user double-clicks to expand a single node.
const EXPAND_NEIGHBOR_LIMIT = 50;
const GROUP_ENTITY = 'Group';

const ORDERED_LEGEND_TYPES = Object.freeze([
  'group',
  'project',
  'user',
  'mergerequest',
  'workitem',
  'pipeline',
  'vulnerability',
  'note',
  'milestone',
  'label',
  'branch',
  'file',
  'directory',
  'definition',
]);

export default defineComponent({
  name: 'GraphExplorer',
  compatConfig: { MODE: 3 },
  components: {
    GlButton,
    GlButtonGroup,
    GlLoadingIcon,
    GraphFilterBar,
    GraphLegend,
    ExplorerNodeSidebar,
    ExplorerQueryPanel,
    ExplorerTablePanel,
    GraphCanvas,
    NodeDetailOverlay,
  },
  isDarkMode: darkModeEnabled(),
  TAB_GRAPH,
  TAB_TABLE,
  props: {
    initialNodes: {
      type: Array,
      required: false,
      default: () => [],
    },
    initialEdges: {
      type: Array,
      required: false,
      default: () => [],
    },
    fillContainer: {
      type: Boolean,
      required: false,
      default: false,
    },
    schema: {
      type: Object,
      required: false,
      default: null,
    },
    activeTypeFilters: {
      type: Set,
      required: false,
      default: () => new Set(),
    },
    instanceMapRequest: {
      type: Object,
      required: false,
      default: null,
    },
    isExpanded: {
      type: Boolean,
      required: false,
      default: false,
    },
    advancedOpen: {
      type: Boolean,
      required: false,
      default: false,
    },
    view: {
      type: String,
      required: false,
      default: TAB_GRAPH,
    },
    mapMode: {
      type: String,
      required: false,
      default: '3d',
    },
    initialQuery: {
      type: Object,
      required: false,
      default: null,
    },
  },
  emits: ['fullscreen-change', 'update-active-type-filters', 'node-counts-change'],
  data() {
    // Personalize the templates with the live current_user_id so "my MRs"
    // and "my neighbors" return useful results out of the box; falls back
    // to user 1 (the typical root admin id) if gon isn't set.
    const exampleQueries = buildExampleQueries({
      currentUserId: window.gon?.current_user_id,
    });
    return {
      exampleQueries,
      templateItems: exampleQueries.map((q) => ({ value: q.value, text: q.text })),
      queryText: this.initialQuery || exampleQueries[0].query,
      selectedTemplate: null,
      rawQueryResult: null,
      loading: false,
      selectedNode: null,
      hoveredNode: null,
      hoveredPosition: null,
      searchQuery: '',
      expandedNodeIds: {},
      graphExpanded: false,
      hintDismissed: false,
      nodes: [],
      edges: [],
      highlightedTypes: new Set(),
    };
  },
  computed: {
    schemaNodes() {
      return this.schema?.nodes || [];
    },
    stringifiedQueryText() {
      if (typeof this.queryText === 'string') return this.queryText;
      return JSON.stringify(this.queryText, null, 2);
    },
    queryResponse() {
      return this.rawQueryResult?.result || null;
    },
    generatedSql() {
      return this.rawQueryResult?.generated_sql || '';
    },
    nodeStyleMap() {
      return buildNodeStyleMap(this.schemaNodes);
    },
    entityColors() {
      return { ...ENTITY_TYPE_COLORS, ...entityColorsFromSchema(this.schemaNodes) };
    },
    entityNames() {
      return { ...ENTITY_TYPE_NAMES, ...entityNamesFromSchema(this.schemaNodes) };
    },
    selectedNodeId() {
      return this.selectedNode ? this.selectedNode.id : null;
    },
    resultCount() {
      if (!this.queryResponse) return null;
      return this.queryResponse.row_count ?? this.nodes.length;
    },
    typeCounts() {
      const counts = {};
      for (const n of this.nodes) {
        if (n.type) {
          const t = n.type.toLowerCase();
          counts[t] = (counts[t] || 0) + 1;
        }
      }
      return counts;
    },
    legendItems() {
      const types =
        this.schemaNodes.length > 0
          ? ORDERED_LEGEND_TYPES.filter((t) => this.entityColors[t])
          : ORDERED_LEGEND_TYPES.filter((t) => this.typeCounts[t] && this.entityColors[t]);

      return types.map((t) => ({
        type: t,
        color: this.entityColors[t],
        name: this.entityNames[t] || t,
        count: this.typeCounts[t] || null,
      }));
    },
  },
  watch: {
    graphExpanded(val) {
      this.$emit('fullscreen-change', val);
    },
    instanceMapRequest(req) {
      if (req) this.executeInstanceMapQuery(req);
    },
    highlightedTypes(filters) {
      this.$nextTick(() => {
        this.$refs.graphCanvas?.highlightByTypes(filters);
      });
    },
    initialNodes: {
      immediate: true,
      handler(nodes) {
        this.syncInitialGraph(nodes, this.initialEdges);
      },
    },
    initialEdges(edges) {
      this.edges = edges;
    },
    typeCounts: {
      immediate: true,
      handler(counts) {
        this.$emit('node-counts-change', counts);
      },
    },
  },
  mounted() {
    if (this.instanceMapRequest) {
      this.executeInstanceMapQuery(this.instanceMapRequest);
    }
  },
  methods: {
    syncInitialGraph(nodes, edges) {
      this.nodes = nodes;
      this.edges = edges;
      this.expandedNodeIds = {};
      this.selectedNode = null;
      this.rawQueryResult = null;

      if (nodes.length === 0) return;

      this.$nextTick(() => {
        this.$refs.graphCanvas?.setFullData();
        if (!this.instanceMapRequest) {
          this.autoExpandInitialNodes();
        }
      });
    },
    async autoExpandInitialNodes() {
      const groupNodes = this.initialNodes.filter((n) => n.type === 'group' && n.properties?.id);
      if (groupNodes.length === 0) return;

      const ids = groupNodes
        .map((n) => Number(n.properties?.id))
        .filter((id) => Number.isFinite(id))
        .slice(0, INITIAL_NODE_IDS_CAP);
      if (ids.length === 0) return;

      const cacheKey = `initial-neighbors:${GROUP_ENTITY}:${[...ids].sort().join(',')}:${INITIAL_NEIGHBOR_LIMIT}`;

      this.loading = true;
      try {
        const response = await withCache(cacheKey, FIVE_MINUTES_MS, async () => {
          const { data } = await executeOrbitQuery({
            query_type: 'neighbors',
            node: { id: 'center', entity: GROUP_ENTITY, node_ids: ids },
            neighbors: { node: 'center', direction: 'both' },
            limit: INITIAL_NEIGHBOR_LIMIT,
          });
          return data?.result || {};
        });

        const { newNodes, newEdges } = mergeNeighborNodes(response, this.nodes, this.nodeStyleMap);

        if (newNodes.length > 0) {
          this.nodes = [...this.nodes, ...newNodes];
          this.edges = [...this.edges, ...newEdges];
          this.$refs.graphCanvas?.addData(newNodes, newEdges);
        }

        const expanded = { ...this.expandedNodeIds };
        for (const node of groupNodes) expanded[node.id] = true;
        this.expandedNodeIds = expanded;
      } catch (err) {
        createAlert({
          message: err.message || s__('Orbit|Failed to load initial graph neighbors.'),
        });
      } finally {
        this.loading = false;
      }
    },
    clearQuery() {
      this.queryText = {};
      this.selectedTemplate = null;
    },
    onTemplateSelect(value) {
      const template = this.exampleQueries.find((q) => q.value === value);
      if (template) {
        this.queryText = template.query;
        this.selectedTemplate = value;
      }
    },
    onQueryChange(value) {
      try {
        this.queryText = JSON.parse(value);
      } catch {
        this.queryText = value;
      }
    },
    parseQuery() {
      if (typeof this.queryText === 'object' && this.queryText !== null) {
        return this.queryText;
      }
      try {
        return JSON.parse(this.queryText);
      } catch {
        createAlert({ message: s__('Orbit|Invalid JSON query. Please check the syntax.') });
        return null;
      }
    },
    async executeCurrentQuery() {
      const parsedQuery = this.parseQuery();
      if (!parsedQuery) return;

      this.loading = true;
      try {
        const { data } = await executeOrbitQuery(parsedQuery);
        this.rawQueryResult = data;
        this.expandedNodeIds = {};
        this.selectedNode = null;

        const result = data?.result || {};
        const { nodes, edges } = transformGraphResponse(result, this.nodeStyleMap);
        this.nodes = nodes;
        this.edges = edges;

        if (nodes.length > 0) {
          this.$nextTick(() => {
            this.$refs.graphCanvas?.setFullData();
          });
        }
      } catch (err) {
        createAlert({
          message: err.message || s__('Orbit|Failed to execute query. Please try again.'),
        });
      } finally {
        this.loading = false;
      }
    },
    onNodeSelect(node) {
      this.selectedNode = node;
      this.hintDismissed = true;
    },
    onNodeHover(node, position) {
      this.hoveredNode = node;
      this.hoveredPosition = position;
    },
    onNodeExpand(node) {
      this.expandNode(node);
    },
    closeSidebar() {
      this.selectedNode = null;
    },
    resolveEntityType(lowercaseType) {
      return this.entityNames[lowercaseType] || ENTITY_TYPE_NAMES[lowercaseType] || lowercaseType;
    },
    async expandNode(node) {
      if (this.expandedNodeIds[node.id]) return;

      const entityType = this.resolveEntityType(node.type || 'user');
      const numericId = Number(node.properties?.id);
      if (!Number.isFinite(numericId)) return;

      this.loading = true;
      try {
        const { data } = await executeOrbitQuery({
          query_type: 'neighbors',
          node: { id: 'center', entity: entityType, node_ids: [numericId] },
          neighbors: { node: 'center', direction: 'both' },
          limit: EXPAND_NEIGHBOR_LIMIT,
        });

        const response = data.result || {};
        const canvas = this.$refs.graphCanvas;
        const graphNodes = this.nodes;
        const { newNodes, newEdges } = mergeNeighborNodes(response, graphNodes, this.nodeStyleMap);

        if (newNodes.length > 0) {
          this.nodes = [...this.nodes, ...newNodes];
          this.edges = [...this.edges, ...newEdges];
          canvas?.addData(newNodes, newEdges);
        }

        this.expandedNodeIds = { ...this.expandedNodeIds, [node.id]: true };
      } catch (err) {
        createAlert({
          message: err.message || s__('Orbit|Failed to expand node neighbors.'),
        });
      } finally {
        this.loading = false;
      }
    },
    onRowClick(row) {
      if (!row.type || row.id === undefined) return;

      const graphId = toGraphId(row.type, row.id);
      const match = this.nodes.find((n) => n.id === graphId);
      if (!match) {
        createAlert({ message: s__('Orbit|Could not locate the selected node in the graph.') });
        return;
      }
      this.selectedNode = match;
    },
    zoomIn() {
      this.$refs.graphCanvas?.zoomIn();
    },
    zoomOut() {
      this.$refs.graphCanvas?.zoomOut();
    },
    onLegendTypeSelect(type) {
      const isSolo = this.highlightedTypes.size === 1 && this.highlightedTypes.has(type);
      if (isSolo) {
        this.highlightedTypes = new Set();
        return;
      }
      const updated = new Set();
      updated.add(type);
      this.highlightedTypes = updated;
    },
    restoreInitialGraph() {
      this.searchQuery = '';
      this.nodes = this.initialNodes;
      this.edges = this.initialEdges;
      this.expandedNodeIds = {};
      this.selectedNode = null;
      this.rawQueryResult = null;
      this.$nextTick(() => {
        this.$refs.graphCanvas?.setFullData();
        this.autoExpandInitialNodes();
      });
    },
    async executeGraphSearch({ text, field }) {
      const activeType = this.activeTypeFilters.size === 1 ? [...this.activeTypeFilters][0] : null;
      if (!activeType) return;

      const entityName = this.resolveEntityType(activeType);
      await this.executeInstanceMapQuery({
        entityType: entityName,
        filters: { [field]: text },
      });
    },
    async executeInstanceMapQuery({ entityType, filters = {} }) {
      const nodeFilters = {};
      for (const [key, value] of Object.entries(filters)) {
        if (Array.isArray(value)) {
          nodeFilters[key] = { op: 'in', value };
        } else if (typeof value === 'string') {
          nodeFilters[key] = { op: 'contains', value };
        } else {
          nodeFilters[key] = { op: 'eq', value };
        }
      }

      // GKG rejects traversal queries without selectivity. When the caller
      // doesn't provide a filter (e.g. "Show in Map" from the schema page),
      // fall back to `id > 0` which (a) passes the selectivity check and
      // (b) matches every row regardless of how the backend numbers ids.
      // id_range was tried first but its 100k span misses entities like
      // MergeRequest where ids start at 1_000_000+.
      const effectiveFilters =
        Object.keys(nodeFilters).length > 0 ? nodeFilters : { id: { op: 'gt', value: 0 } };

      const query = {
        query_type: 'traversal',
        node: {
          id: 'n',
          entity: entityType,
          columns: '*',
          filters: effectiveFilters,
        },
        limit: 50,
      };

      this.queryText = query;
      await this.executeCurrentQuery();
    },
  },
});
</script>

<template>
  <div
    data-testid="graph-explorer"
    class="gl-flex gl-flex-col gl-gap-5"
    :class="{
      'gl-fixed gl-inset-0 gl-bg-default': graphExpanded,
      'gl-h-full': fillContainer,
    }"
    :style="graphExpanded ? { zIndex: 9999 } : {}"
  >
    <!-- Advanced panel (query editor) -->
    <div
      v-if="advancedOpen"
      class="orbit-advanced-panel gl-border gl-flex gl-w-full gl-shrink-0 gl-flex-col gl-overflow-hidden gl-rounded-lg gl-bg-subtle"
    >
      <explorer-query-panel
        :query-text="stringifiedQueryText"
        :loading="loading"
        :template-items="templateItems"
        :selected-template="selectedTemplate"
        @update:query-text="onQueryChange"
        @execute="executeCurrentQuery"
        @clear="clearQuery"
        @template-select="onTemplateSelect"
      />
    </div>

    <explorer-table-panel
      v-if="view === $options.TAB_TABLE"
      :query-response="queryResponse"
      :generated-sql="generatedSql"
      :result-count="resultCount"
      :loading="loading"
      class="gl-min-w-0 gl-flex-1"
      @row-click="onRowClick"
    />

    <div
      v-else
      class="orbit-graph-container gl-flex gl-min-w-0 gl-flex-1 gl-flex-col gl-overflow-hidden"
      :class="
        graphExpanded || fillContainer
          ? 'gl-h-full'
          : 'gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-bg-subtle'
      "
    >
      <div class="gl-flex gl-min-h-0 gl-flex-1 gl-flex-col">
        <!-- Globe viewport -->
        <div
          class="gl-relative gl-min-h-0 gl-flex-1 gl-overflow-hidden"
          @mousedown="hintDismissed = true"
        >
          <!-- Search overlay (top-left) -->
          <div
            class="gl-absolute gl-left-3 gl-top-3 gl-z-4 gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-bg-default gl-p-3 gl-shadow-sm"
            data-testid="graph-controls"
          >
            <graph-filter-bar
              :search-query="searchQuery"
              :legend-items="legendItems"
              :active-type-filters="activeTypeFilters"
              :schema-nodes="schemaNodes"
              :loading="loading"
              @update-search-query="searchQuery = $event"
              @update-active-type-filters="$emit('update-active-type-filters', $event)"
              @search-graph="executeGraphSearch"
              @clear-filters="restoreInitialGraph"
            />
          </div>

          <!-- Bottom-right cluster: interaction hint + zoom controls -->
          <div
            class="gl-absolute gl-bottom-3 gl-right-3 gl-z-3 gl-flex gl-items-end gl-gap-5"
            data-testid="graph-zoom-controls"
          >
            <span class="gl-text-sm gl-text-subtle">
              {{ s__('Orbit|Click to select. Double-click to expand. Drag to move.') }}
            </span>
            <gl-button-group vertical>
              <gl-button
                size="small"
                icon="plus"
                :aria-label="s__('Orbit|Zoom in')"
                data-testid="zoom-in"
                @click="zoomIn"
              />
              <gl-button
                size="small"
                icon="dash"
                :aria-label="s__('Orbit|Zoom out')"
                data-testid="zoom-out"
                @click="zoomOut"
              />
            </gl-button-group>
          </div>

          <!-- Legend overlay (bottom-left) -->
          <div
            class="gl-absolute gl-bottom-3 gl-left-3 gl-z-3 gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-bg-default gl-p-3 gl-shadow-sm"
            data-testid="graph-legend-panel"
          >
            <graph-legend
              :items="legendItems"
              :active-type-filters="highlightedTypes"
              :is-compact="!isExpanded && !graphExpanded"
              @select-type="onLegendTypeSelect"
            />
          </div>

          <!-- Expand handled by parent panel -->
          <gl-loading-icon v-if="loading && nodes.length === 0" size="lg" class="gl-mt-20" />

          <graph-canvas
            v-else
            ref="graphCanvas"
            :nodes="nodes"
            :edges="edges"
            :selected-node-id="selectedNodeId"
            :node-style-map="nodeStyleMap"
            :dark-mode="$options.isDarkMode"
            :map-mode="mapMode"
            @node-select="onNodeSelect"
            @node-hover="onNodeHover"
            @node-expand="onNodeExpand"
          />

          <node-detail-overlay
            :node="hoveredNode"
            :position="hoveredPosition"
            :entity-colors="entityColors"
            :entity-names="entityNames"
            :all-nodes="nodes"
          />

          <explorer-node-sidebar
            v-if="selectedNode"
            :node="selectedNode"
            :entity-colors="entityColors"
            :entity-names="entityNames"
            @close="closeSidebar"
          />
        </div>
      </div>
    </div>
  </div>
</template>
