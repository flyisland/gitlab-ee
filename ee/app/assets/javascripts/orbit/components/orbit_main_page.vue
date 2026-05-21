<script>
import { defineComponent } from 'vue';
import { GlButton, GlButtonGroup, GlIcon, GlLoadingIcon } from '@gitlab/ui';
import { createAlert } from '~/alert';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import { s__, sprintf } from '~/locale';
import { fetchOrbitSchema } from '../api/orbit_api';
import {
  ENTITY_TYPE_COLORS,
  ENTITY_TYPE_NAMES,
  TAB_GRAPH,
  TAB_TABLE,
  VIEW_2D,
  VIEW_3D,
} from '../constants';
import { toGraphId } from '../utils/graph_transform';
import { fetchCombinedGraphStats } from '../utils/graph_stats';
import { ENABLED_MEMBER_NAMESPACES_LIMIT } from '../utils/namespace_limits';
import enabledMemberNamespacesQuery from '../graphql/queries/enabled_member_namespaces.query.graphql';
import memberNamespacesQuery from '../graphql/queries/member_namespaces.query.graphql';
import GraphExplorer from './graph_explorer.vue';
import OrbitExploreEmptyState from './orbit_explore_empty_state.vue';

const PANEL_MAP = 'map';
const VALID_PANELS = new Set([PANEL_MAP]);
const GROUP_NODE_TYPE = 'Group';
const EMPTY_EDGES = Object.freeze([]);

const getGroupNumericId = (group) => getIdFromGraphQLId(group?.id);
const isSdlcMapTopLevelGroup = (group) =>
  group?.knowledgeGraphEnabled === true &&
  Boolean(group.fullPath) &&
  Number.isFinite(getGroupNumericId(group));

const VIEW_ITEMS = Object.freeze([
  { value: TAB_GRAPH, icon: 'earth', label: s__('Orbit|Map'), testid: 'view-map' },
  { value: TAB_TABLE, icon: 'table', label: s__('Orbit|Table'), testid: 'view-table' },
]);

const DIMENSION_ITEMS = Object.freeze([
  { value: VIEW_2D, label: s__('Orbit|2D'), testid: 'map-mode-2d' },
  { value: VIEW_3D, label: s__('Orbit|3D'), testid: 'map-mode-3d' },
]);

export default defineComponent({
  name: 'OrbitMainPage',
  compatConfig: { MODE: 3 },
  components: {
    GlButton,
    GlButtonGroup,
    GlIcon,
    GlLoadingIcon,
    GraphExplorer,
    OrbitExploreEmptyState,
  },
  emptyEdges: EMPTY_EDGES,
  viewItems: VIEW_ITEMS,
  dimensionItems: DIMENSION_ITEMS,
  apollo: {
    enabledMemberGroups: {
      query: enabledMemberNamespacesQuery,
      variables: { first: ENABLED_MEMBER_NAMESPACES_LIMIT },
      update(data) {
        return data?.groups?.nodes || [];
      },
      result({ loading }) {
        if (!loading) this.enabledMemberGroupsLoaded = true;
      },
      error(err) {
        this.enabledMemberGroupsLoaded = true;
        createAlert({
          message: err.message || s__('Orbit|Failed to load groups.'),
        });
      },
    },
    memberGroups: {
      query: memberNamespacesQuery,
      variables: { first: 25 },
      skip() {
        return !this.enabledMemberGroupsLoaded || this.hasEnabledGroups;
      },
      update(data) {
        return data?.groups?.nodes || [];
      },
      error(err) {
        createAlert({
          message: err.message || s__('Orbit|Failed to load groups.'),
        });
      },
    },
  },
  data() {
    const params = new URLSearchParams(window.location.search);
    const panel = params.get('panel');
    const entity = params.get('entity');
    return {
      enabledMemberGroups: [],
      enabledMemberGroupsLoaded: false,
      memberGroups: [],
      expandedPanel: panel && VALID_PANELS.has(panel) ? panel : null,
      schema: null,
      activeTypeFilters: new Set(),
      advancedOpen: false,
      view: TAB_GRAPH,
      mapMode: VIEW_3D,
      instanceMapRequest: entity ? { entityType: entity, filters: {} } : null,
      displayedTypeCounts: {},
      indexedGraphStats: null,
    };
  },
  computed: {
    enabledGroupsLoading() {
      return this.$apollo.queries.enabledMemberGroups.loading;
    },
    memberGroupsLoading() {
      return this.$apollo.queries.memberGroups.loading;
    },
    loading() {
      return (
        this.enabledGroupsLoading ||
        (!this.enabledMemberGroupsLoaded && !this.hasEnabledGroups) ||
        (!this.hasEnabledGroups && this.memberGroupsLoading)
      );
    },
    hasEnabledGroups() {
      return this.enabledMemberGroups.length > 0;
    },
    sdlcMapTopLevelGroups() {
      return this.enabledMemberGroups
        .slice(0, ENABLED_MEMBER_NAMESPACES_LIMIT)
        .filter(isSdlcMapTopLevelGroup);
    },
    initialGroupNodes() {
      return this.sdlcMapTopLevelGroups.map((g) => {
        const numericId = getGroupNumericId(g);
        return {
          id: toGraphId(GROUP_NODE_TYPE, numericId),
          type: 'group',
          label: g.name,
          domain: 'project',
          color: ENTITY_TYPE_COLORS.group,
          entityName: ENTITY_TYPE_NAMES.group,
          avatarUrl: g.avatarUrl,
          knowledgeGraphEnabled: g.knowledgeGraphEnabled,
          properties: {
            id: numericId,
            name: g.name,
            full_name: g.fullName,
            full_path: g.fullPath,
            knowledge_graph_enabled: g.knowledgeGraphEnabled,
          },
        };
      });
    },
    isMapExpanded() {
      return this.expandedPanel === PANEL_MAP;
    },
    isMapView() {
      return this.view === TAB_GRAPH;
    },
    enabledNamespacePaths() {
      return this.sdlcMapTopLevelGroups.map((group) => group.fullPath);
    },
    displayedNodeCount() {
      return Object.values(this.displayedTypeCounts).reduce((total, count) => {
        const value = Number(count);
        return Number.isFinite(value) ? total + value : total;
      }, 0);
    },
    indexCountLabel() {
      if (!this.indexedGraphStats) return '';

      const total = this.indexedGraphStats.getTotalIndexedNodes();
      if (!total) return '';

      const returned = Math.min(this.displayedNodeCount, total);
      return sprintf(s__('Orbit|Showing %{returned} of %{total} indexed nodes.'), {
        returned: returned.toLocaleString(),
        total: total.toLocaleString(),
      });
    },
  },
  watch: {
    expandedPanel() {
      const url = new URL(window.location.href);
      if (this.expandedPanel) {
        url.searchParams.set('panel', this.expandedPanel);
      } else {
        url.searchParams.delete('panel');
      }
      window.history.replaceState(null, '', url.toString());
    },
    enabledMemberGroups: {
      immediate: true,
      handler() {
        this.loadIndexedTotals();
      },
    },
  },
  async mounted() {
    await this.loadSharedSchema();
  },
  methods: {
    togglePanel(panel) {
      this.expandedPanel = this.expandedPanel === panel ? null : panel;
    },
    toggleAdvanced() {
      this.advancedOpen = !this.advancedOpen;
    },
    onTypeFilterChange(filters) {
      this.activeTypeFilters = filters;
    },
    async loadSharedSchema() {
      try {
        const { data } = await fetchOrbitSchema({ expand: '*' });
        this.schema = data;
      } catch {
        // Schema is non-critical: child explorer falls back to defaults.
      }
    },
    async loadIndexedTotals() {
      if (!this.enabledNamespacePaths.length) {
        this.indexedGraphStats = null;
        return;
      }

      this.indexedGraphStats = await fetchCombinedGraphStats(this.enabledNamespacePaths);
    },
    onNodeCountsChange(counts) {
      this.displayedTypeCounts = counts;
    },
  },
});
</script>

<template>
  <div class="gl-flex gl-flex-1 gl-flex-col gl-gap-5" data-testid="orbit-main-page">
    <gl-loading-icon v-if="loading" size="lg" class="gl-mt-11" />

    <orbit-explore-empty-state v-else-if="!hasEnabledGroups" :available-groups="memberGroups" />

    <template v-else>
      <!-- Fullscreen map overlay -->
      <div
        v-if="isMapExpanded"
        class="orbit-fullscreen-overlay gl-fixed gl-inset-0 gl-flex gl-flex-col gl-bg-default gl-p-3"
        data-testid="expanded-overlay"
      >
        <div
          class="gl-border-b gl-mb-2 gl-flex gl-items-center gl-justify-between gl-border-default gl-pb-2"
        >
          <span class="gl-flex gl-items-center gl-gap-2 gl-text-lg gl-font-bold">
            <gl-icon name="earth" :size="16" />
            {{ s__('Orbit|Orbit') }}
            <span class="gl-font-normal gl-text-subtle">/</span>
            {{ s__('Orbit|SDLC Map') }}
          </span>
          <gl-button
            size="small"
            category="tertiary"
            icon="minimize"
            :aria-label="s__('Orbit|Exit full screen')"
            @click="togglePanel('map')"
          />
        </div>
        <div
          class="gl-border gl-flex gl-min-h-0 gl-flex-1 gl-flex-col gl-overflow-hidden gl-rounded-base gl-border-solid gl-border-default"
        >
          <graph-explorer
            :initial-nodes="initialGroupNodes"
            :initial-edges="$options.emptyEdges"
            :schema="schema"
            :active-type-filters="activeTypeFilters"
            :instance-map-request="instanceMapRequest"
            :advanced-open="advancedOpen"
            :view="view"
            :map-mode="mapMode"
            is-expanded
            fill-container
            @update-active-type-filters="onTypeFilterChange"
          />
        </div>
      </div>

      <!-- Normal layout -->
      <div v-if="!isMapExpanded" class="orbit-main-page-content gl-flex gl-flex-col gl-gap-3">
        <div class="gl-flex gl-items-center gl-gap-3 gl-p-2" data-testid="explorer-toolbar">
          <gl-button
            size="small"
            icon="search-results"
            :selected="advancedOpen"
            data-testid="toggle-advanced"
            @click="toggleAdvanced"
          >
            {{ s__('Orbit|Advanced query') }}
          </gl-button>
          <div
            class="gl-h-5 gl-w-px gl-bg-strong"
            role="separator"
            aria-orientation="vertical"
          ></div>
          <gl-button-group>
            <gl-button
              v-for="item in $options.viewItems"
              :key="item.value"
              size="small"
              :icon="item.icon"
              :selected="view === item.value"
              :data-testid="item.testid"
              @click="view = item.value"
            >
              {{ item.label }}
            </gl-button>
          </gl-button-group>
          <gl-button-group v-if="isMapView">
            <gl-button
              v-for="item in $options.dimensionItems"
              :key="item.value"
              size="small"
              :selected="mapMode === item.value"
              :data-testid="item.testid"
              @click="mapMode = item.value"
            >
              {{ item.label }}
            </gl-button>
          </gl-button-group>
        </div>

        <graph-explorer
          class="orbit-main-graph"
          data-testid="panel-map"
          :initial-nodes="initialGroupNodes"
          :initial-edges="$options.emptyEdges"
          :schema="schema"
          :active-type-filters="activeTypeFilters"
          :instance-map-request="instanceMapRequest"
          :advanced-open="advancedOpen"
          :view="view"
          :map-mode="mapMode"
          @update-active-type-filters="onTypeFilterChange"
          @node-counts-change="onNodeCountsChange"
        />

        <p
          v-if="indexCountLabel"
          class="gl-mb-0 gl-mt-0 gl-text-sm gl-text-subtle"
          data-testid="orbit-index-count"
        >
          {{ indexCountLabel }}
        </p>
      </div>
    </template>
  </div>
</template>
