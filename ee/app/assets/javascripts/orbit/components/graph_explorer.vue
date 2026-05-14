<script>
import { defineComponent } from 'vue';
import { GlLoadingIcon } from '@gitlab/ui';
import gitlabLogoSvg from '@gitlab/svgs/dist/illustrations/gitlab_logo.svg?url';
import { createAlert } from '~/alert';
import { DOCS_URL } from '~/constants';
import { setCookie, getCookie } from '~/lib/utils/common_utils';
import { darkModeEnabled } from '~/lib/utils/color_utils';
import { s__ } from '~/locale';
import { executeOrbitQuery, fetchOrbitSchema } from '../api/orbit_api';
import {
  EXAMPLE_QUERIES,
  ENTITY_TYPE_COLORS,
  ENTITY_TYPE_NAMES,
  VIEW_3D,
  TAB_GRAPH,
  TAB_TABLE,
} from '../constants';
import ownedNamespacesQuery from '../graphql/queries/owned_namespaces.query.graphql';
import { transformGraphResponse, mergeNeighborNodes, toGraphId } from '../utils/graph_transform';
import {
  buildNodeStyleMap,
  entityColorsFromSchema,
  entityNamesFromSchema,
} from '../utils/node_style_map';
import ExplorerGraphToolbar from './explorer_graph_toolbar.vue';
import ExplorerHeroBanner from './explorer_hero_banner.vue';
import ExplorerNodeSidebar from './explorer_node_sidebar.vue';
import ExplorerQueryPanel from './explorer_query_panel.vue';
import ExplorerTabBar from './explorer_tab_bar.vue';
import ExplorerTablePanel from './explorer_table_panel.vue';
import GraphCanvas from './graph_canvas.vue';
import NodeDetailOverlay from './node_detail_overlay.vue';

const GROUP_NODE_TYPE = 'Group';

export default defineComponent({
  name: 'GraphExplorer',
  compatConfig: { MODE: 3 },
  components: {
    GlLoadingIcon,
    ExplorerGraphToolbar,
    ExplorerHeroBanner,
    ExplorerNodeSidebar,
    ExplorerQueryPanel,
    ExplorerTabBar,
    ExplorerTablePanel,
    GraphCanvas,
    NodeDetailOverlay,
  },
  isDarkMode: darkModeEnabled(),
  learnMorePath: `${DOCS_URL}/orbit/`,
  logoSrc: gitlabLogoSvg,
  templateItems: EXAMPLE_QUERIES.map((q) => ({ value: q.value, text: q.text })),
  apollo: {
    ownedGroups: {
      query: ownedNamespacesQuery,
      variables: { first: 25 },
      update(data) {
        const groups = data?.groups?.nodes || [];
        return groups.map((g) => {
          const numericId = g.id ? g.id.split('/').pop() : g.fullPath;
          return {
            id: toGraphId(GROUP_NODE_TYPE, numericId),
            label: g.name,
            type: 'group',
            domain: 'project',
            fullPath: g.fullPath,
            avatarUrl: g.avatarUrl,
            knowledgeGraphEnabled: g.knowledgeGraphEnabled,
            properties: {
              id: Number(numericId),
              name: g.name,
              fullName: g.fullName,
              fullPath: g.fullPath,
              knowledgeGraphEnabled: g.knowledgeGraphEnabled,
            },
          };
        });
      },
      result() {
        this.initialLoading = false;
        if (!this.ownedGroups?.length) return;

        this.nodes = this.ownedGroups;
        this.edges = [];
        this.$nextTick(() => {
          this.$refs.graphCanvas?.setFullData();
        });
      },
      error(err) {
        this.initialLoading = false;
        createAlert({
          message: err.message || s__('Orbit|Failed to load groups.'),
        });
      },
    },
  },
  data() {
    return {
      queryText: EXAMPLE_QUERIES[0].query,
      rawQueryResult: null,
      loading: false,
      initialLoading: true,
      activeTab: TAB_GRAPH,
      dimensionMode: VIEW_3D,
      selectedNode: null,
      hoveredNode: null,
      hoveredPosition: null,
      searchQuery: '',
      expandedNodeIds: {},
      schemaNodes: [],
      bannerDismissed: getCookie('orbit_banner_dismissed') === 'true',
      tableExpanded: false,
      graphExpanded: false,
      nodes: [],
      edges: [],
      ownedGroups: [],
    };
  },
  computed: {
    stringifiedQueryText() {
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
      return this.queryResponse?.row_count ?? this.nodes.length;
    },
    showQueryPanel() {
      return (
        !(this.activeTab === TAB_TABLE && this.tableExpanded) &&
        !(this.activeTab === TAB_GRAPH && this.graphExpanded)
      );
    },
    isGraphTab() {
      return this.activeTab === TAB_GRAPH;
    },
    contentStyle() {
      const offset = this.bannerDismissed ? '17rem' : '28rem';
      return { height: `calc(100vh - ${offset})`, minHeight: '25rem' };
    },
  },
  watch: {
    bannerDismissed(dismissed) {
      if (dismissed) {
        setCookie('orbit_banner_dismissed', 'true', { expires: 365 });
      }
    },
  },
  async mounted() {
    await this.loadSchema();
  },
  methods: {
    async loadSchema() {
      try {
        const { data } = await fetchOrbitSchema();
        this.schemaNodes = data.nodes;
      } catch {
        // schema is non-critical; computed properties fall back to defaults
      }
    },
    onTemplateSelect(value) {
      const template = EXAMPLE_QUERIES.find((q) => q.value === value);
      if (template) {
        this.queryText = template.query;
      }
    },
    onQueryChange(value) {
      try {
        this.queryText = JSON.parse(value);
      } catch {
        // keep raw string while user is typing invalid JSON
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
    dismissBanner() {
      this.bannerDismissed = true;
    },
    filterGraph(query) {
      const q = query?.trim();
      if (!q || q.length < 2) return;

      const [firstMatch] = this.$refs.graphCanvas?.searchNodes(q) || [];
      if (firstMatch) {
        this.selectedNode = firstMatch;
        this.$refs.graphCanvas?.graph?.selectNode(firstMatch.index);
      }
    },
    onNodeSelect(node) {
      this.selectedNode = node;
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
          limit: 30,
        });

        const response = data.result || {};
        const canvas = this.$refs.graphCanvas;
        const graphNodes = canvas?.graph?.nodes || this.nodes;
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

      this.activeTab = TAB_GRAPH;
      const graphId = toGraphId(row.type, row.id);
      const match = this.nodes.find((n) => n.id === graphId);
      if (!match) {
        createAlert({ message: s__('Orbit|Could not locate the selected node in the graph.') });
        return;
      }
      this.selectedNode = match;
    },
  },
});
</script>

<template>
  <div class="gl-pt-5" data-testid="graph-explorer">
    <h1 class="gl-my-0 gl-mb-5">{{ s__('Orbit|Data Explorer') }}</h1>

    <explorer-hero-banner
      v-if="!bannerDismissed"
      :logo-src="$options.logoSrc"
      @dismiss="dismissBanner"
    />

    <div
      class="gl-overflow-hidden gl-rounded-lg gl-border-1 gl-border-solid gl-border-default gl-bg-subtle"
    >
      <explorer-tab-bar
        :active-tab="activeTab"
        :show-resource-links="bannerDismissed"
        @update:active-tab="activeTab = $event"
      />

      <div class="gl-flex" :style="contentStyle">
        <explorer-query-panel
          v-if="showQueryPanel"
          :query-text="stringifiedQueryText"
          :loading="loading"
          :template-items="$options.templateItems"
          @update:query-text="onQueryChange"
          @execute="executeCurrentQuery"
          @clear="queryText = {}"
          @template-select="onTemplateSelect"
        />

        <div
          v-if="isGraphTab"
          class="gl-border-l gl-flex gl-flex-1 gl-flex-col gl-overflow-hidden gl-border-default gl-bg-subtle"
          :class="{ 'gl-border-l-0': graphExpanded }"
          data-testid="graph-view"
        >
          <explorer-graph-toolbar
            :search-query="searchQuery"
            :dimension-mode="dimensionMode"
            :expanded="graphExpanded"
            @update-search-query="
              searchQuery = $event;
              filterGraph($event);
            "
            @select-dimension="dimensionMode = $event"
            @toggle-expand="graphExpanded = !graphExpanded"
          />

          <div class="gl-relative gl-flex-1">
            <gl-loading-icon
              v-if="initialLoading || (loading && nodes.length === 0)"
              size="lg"
              class="gl-mt-20"
            />

            <graph-canvas
              v-else
              ref="graphCanvas"
              :nodes="nodes"
              :edges="edges"
              :selected-node-id="selectedNodeId"
              :view-mode="dimensionMode"
              :node-style-map="nodeStyleMap"
              :dark-mode="$options.isDarkMode"
              @node-select="onNodeSelect"
              @node-hover="onNodeHover"
              @node-expand="onNodeExpand"
            />

            <node-detail-overlay
              :node="hoveredNode"
              :position="hoveredPosition"
              :entity-colors="entityColors"
              :entity-names="entityNames"
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

        <explorer-table-panel
          v-else
          :query-response="queryResponse"
          :generated-sql="generatedSql"
          :result-count="resultCount"
          :loading="loading"
          :expanded="tableExpanded"
          @toggle-expand="tableExpanded = !tableExpanded"
          @row-click="onRowClick"
        />
      </div>
    </div>
  </div>
</template>
