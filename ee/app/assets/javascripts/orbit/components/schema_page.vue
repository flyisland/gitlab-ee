<script>
import { defineComponent } from 'vue';
import { GlBadge, GlButton, GlButtonGroup, GlLoadingIcon, GlSearchBoxByType } from '@gitlab/ui';
import { createAlert } from '~/alert';
import { s__ } from '~/locale';
import { fetchOrbitSchema } from '../api/orbit_api';
import { buildNodeStyleMap } from '../utils/node_style_map';
import {
  mapSchemaDomains,
  buildNodeDomainMap,
  buildDomainColorMap,
  resolveNodeColor,
  filterSchemaNodes,
  filterSchemaEdges,
} from '../utils/schema_mappers';
import SchemaDomainSidebar from './schema_domain_sidebar.vue';
import SchemaNodeCard from './schema_node_card.vue';
import SchemaEdgeCard from './schema_edge_card.vue';

const TAB_NODE_TYPES = 'nodeTypes';
const TAB_RELATIONSHIPS = 'relationships';

export default defineComponent({
  name: 'SchemaPage',
  compatConfig: { MODE: 3 },
  components: {
    GlBadge,
    GlButton,
    GlButtonGroup,
    GlLoadingIcon,
    GlSearchBoxByType,
    SchemaDomainSidebar,
    SchemaNodeCard,
    SchemaEdgeCard,
  },
  data() {
    return {
      schema: null,
      loading: true,
      activeTab: TAB_NODE_TYPES,
      selectedDomain: null,
      searchQuery: '',
      collapsedCards: {},
      collapsedEdges: {},
      expandedDomains: {},
      nodeStyleMap: {},
      highlightedNode: null,
      highlightTimer: null,
    };
  },
  computed: {
    domains() {
      return mapSchemaDomains(this.schema?.domains);
    },
    nodeDomainMap() {
      return buildNodeDomainMap(this.schema?.nodes);
    },
    domainColorMap() {
      return buildDomainColorMap(this.schema?.nodes, this.nodeStyleMap);
    },
    filteredNodes() {
      return filterSchemaNodes(this.schema?.nodes, {
        domain: this.selectedDomain,
        query: this.searchQuery,
      });
    },
    filteredEdges() {
      return filterSchemaEdges(this.schema?.edges, this.schema?.nodes, {
        domain: this.selectedDomain,
        query: this.searchQuery,
      });
    },
  },
  beforeUnmount() {
    clearTimeout(this.highlightTimer);
  },
  mounted() {
    this.loadSchema();
  },
  methods: {
    async loadSchema() {
      this.loading = true;
      try {
        const { data } = await fetchOrbitSchema({ expand: '*' });
        this.schema = data;
        this.nodeStyleMap = buildNodeStyleMap(this.schema?.nodes);
      } catch {
        createAlert({ message: s__('Orbit|Failed to load schema. Please try again.') });
      } finally {
        this.loading = false;
      }
    },
    selectDomain(domain) {
      this.selectedDomain = domain;
      if (domain) {
        this.expandedDomains = { ...this.expandedDomains, [domain]: true };
      }
    },
    toggleDomainExpand(domainName) {
      this.expandedDomains = {
        ...this.expandedDomains,
        [domainName]: !this.expandedDomains[domainName],
      };
    },
    toggleNodeCollapse(name) {
      this.collapsedCards = { ...this.collapsedCards, [name]: !this.collapsedCards[name] };
    },
    isNodeCollapsed(name) {
      return Boolean(this.collapsedCards[name]);
    },
    toggleEdgeCollapse(name) {
      this.collapsedEdges = { ...this.collapsedEdges, [name]: !this.collapsedEdges[name] };
    },
    isEdgeCollapsed(name) {
      return Boolean(this.collapsedEdges[name]);
    },
    setActiveTab(tab) {
      this.activeTab = tab;
    },
    nodeColor(node) {
      return resolveNodeColor(node.name, {
        nodeStyleMap: this.nodeStyleMap,
        domainColorMap: this.domainColorMap,
        nodeDomainMap: this.nodeDomainMap,
      });
    },
    highlightNode(nodeName) {
      this.activeTab = TAB_NODE_TYPES;
      this.highlightedNode = nodeName;
      this.$nextTick(() => {
        const escaped = nodeName.replace(/"/g, '\\"');
        const el = this.$el.querySelector(`[data-node-name="${escaped}"]`);
        if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
      });
      clearTimeout(this.highlightTimer);
      this.highlightTimer = setTimeout(() => {
        this.highlightedNode = null;
      }, 1500);
    },
  },
  TAB_NODE_TYPES,
  TAB_RELATIONSHIPS,
});
</script>

<template>
  <div class="gl-pt-5" data-testid="schema-page">
    <h1 class="gl-my-0 gl-mb-5">{{ s__('Orbit|Schema') }}</h1>

    <gl-loading-icon v-if="loading" size="lg" class="gl-my-6" />

    <div
      v-else-if="schema"
      class="schema-page-content gl-flex gl-rounded-lg gl-border-1 gl-border-solid gl-border-default"
      data-testid="schema-content"
    >
      <schema-domain-sidebar
        :domains="domains"
        :selected-domain="selectedDomain"
        :total-node-count="schema?.nodes?.length ?? 0"
        :expanded-domains="expandedDomains"
        :domain-color-map="domainColorMap"
        @select-domain="selectDomain"
        @toggle-expand="toggleDomainExpand"
        @select-node="highlightNode"
      />

      <div class="gl-flex gl-min-w-0 gl-flex-1 gl-flex-col">
        <div
          class="gl-flex gl-items-center gl-gap-3 gl-bg-strong gl-px-4 gl-py-3"
          data-testid="schema-tab-bar"
        >
          <gl-button-group>
            <gl-button
              :selected="activeTab === $options.TAB_NODE_TYPES"
              size="small"
              data-testid="tab-node-types"
              @click="setActiveTab($options.TAB_NODE_TYPES)"
            >
              {{ s__('Orbit|Node Types') }}
              <gl-badge size="sm" class="gl-ml-1">{{ filteredNodes.length }}</gl-badge>
            </gl-button>
            <gl-button
              :selected="activeTab === $options.TAB_RELATIONSHIPS"
              size="small"
              data-testid="tab-relationships"
              @click="setActiveTab($options.TAB_RELATIONSHIPS)"
            >
              {{ s__('Orbit|Relationships') }}
              <gl-badge size="sm" class="gl-ml-1">{{ filteredEdges.length }}</gl-badge>
            </gl-button>
          </gl-button-group>

          <div class="gl-flex-1"></div>

          <gl-search-box-by-type
            v-model="searchQuery"
            :placeholder="s__('Orbit|Search nodes and relationships...')"
            class="schema-search-box"
            data-testid="schema-search"
          />
        </div>

        <div
          v-if="activeTab === $options.TAB_RELATIONSHIPS"
          class="gl-px-4 gl-py-3 gl-text-sm gl-text-subtle"
        >
          {{
            s__(
              'Orbit|Define how node types connect to each other. Relationships are also known as edges.',
            )
          }}
        </div>

        <div
          v-if="activeTab === $options.TAB_NODE_TYPES"
          class="gl-flex-1 gl-overflow-y-auto gl-p-4"
          data-testid="node-types-content"
        >
          <div class="schema-grid">
            <schema-node-card
              v-for="node in filteredNodes"
              :key="node.name"
              :data-node-name="node.name"
              :node="node"
              :collapsed="isNodeCollapsed(node.name)"
              :node-color="nodeColor(node)"
              :class="{ 'schema-node-highlight': highlightedNode === node.name }"
              @toggle-collapse="toggleNodeCollapse"
            />
          </div>
        </div>

        <div
          v-else-if="activeTab === $options.TAB_RELATIONSHIPS"
          class="gl-flex-1 gl-overflow-y-auto gl-p-4"
          data-testid="relationships-content"
        >
          <div class="schema-grid">
            <schema-edge-card
              v-for="edge in filteredEdges"
              :key="edge.name"
              :edge="edge"
              :collapsed="isEdgeCollapsed(edge.name)"
              :node-style-map="nodeStyleMap"
              :node-domain-map="nodeDomainMap"
              :domain-color-map="domainColorMap"
              @toggle-collapse="toggleEdgeCollapse"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.schema-page-content {
  height: calc(100vh - 180px);
  min-height: 500px;
}

.schema-search-box {
  max-width: 280px;
}

.schema-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  align-items: start;
}

.schema-node-highlight {
  animation: node-highlight-pulse 1.5s ease-out;
}

@keyframes node-highlight-pulse {
  0%,
  30% {
    box-shadow: 0 0 0 3px var(--gl-color-blue-500, #1f75cb);
  }
  100% {
    box-shadow: 0 0 0 0 transparent;
  }
}
</style>
