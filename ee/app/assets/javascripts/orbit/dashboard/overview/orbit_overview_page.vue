<script>
import { defineComponent } from 'vue';
import { GlLoadingIcon } from '@gitlab/ui';
import { formatNumber, n__, s__, sprintf } from '~/locale';
import * as Sentry from '~/sentry/sentry_browser_wrapper';
import { fetchOrbitSchema } from 'ee/orbit/api/orbit_api';
import { fetchCombinedGraphStats } from 'ee/orbit/utils/graph_stats';
import { ORBIT_ERROR_KIND, orbitErrorKind } from 'ee/orbit/utils/orbit_errors';
import { toGroupGraphNode } from 'ee/orbit/utils/graph_transform';
import { indexingVersion, isIndexing } from 'ee/orbit/utils/orbit_group_state';
import GraphExplorer from 'ee/orbit/components/graph_explorer.vue';
import { LOAD_STATUS } from '../constants';
import OverviewStatsCard from './overview_stats_card.vue';

const EMPTY_EDGES = Object.freeze([]);

const groupNodesKey = (nodes) =>
  nodes.map((node) => `${node.id}:${node.label}:${node.avatarUrl}`).join('|');

export default defineComponent({
  name: 'OrbitOverviewPage',
  compatConfig: { MODE: 3 },
  components: { GlLoadingIcon, GraphExplorer, OverviewStatsCard },
  inject: ['defaultGroupMissing', 'enabledMemberGroups', 'enabledGroupsCount'],
  data() {
    return {
      schema: null,
      graphStats: null,
      statsStatus: LOAD_STATUS.LOADING,
      statsRequestId: 0,
      displayedCounts: {},
      globeNodes: [],
      mapUnavailable: false,
    };
  },
  computed: {
    indexingProgress() {
      return this.enabledMemberGroups
        .map((group) => `${group.fullPath}:${indexingVersion(group)}`)
        .join('|');
    },
    initialGroupNodes() {
      return this.enabledMemberGroups.map(toGroupGraphNode);
    },
    // A poll hands over new group objects. Only a real change may reset the globe.
    initialGroupNodesKey() {
      return groupNodesKey(this.initialGroupNodes);
    },
    anyIndexing() {
      return this.enabledMemberGroups.some(isIndexing);
    },
    totalIndexedNodes() {
      if (!this.instanceMapRequest) return this.graphStats?.getTotalIndexedNodes() ?? 0;

      const entityCounts = this.graphStats?.getEntityCounts() ?? {};
      return entityCounts[this.instanceMapRequest.entityType.toLowerCase()] ?? 0;
    },
    displayedNodeCount() {
      return Object.values(this.displayedCounts).reduce((sum, count) => sum + count, 0);
    },
    instanceMapRequest() {
      const [entity] = [].concat(this.$route.query.entity ?? []);
      return entity ? { entityType: entity } : null;
    },
    statusLine() {
      return [this.itemsLine, this.groupsLine].filter(Boolean).join(' ');
    },
    itemsLine() {
      if (this.instanceMapRequest) return this.entityItemsLine;

      if (!this.anyIndexing && this.totalIndexedNodes > 0) {
        return sprintf(
          n__(
            'Orbit|Showing %{shown} of %{total} item. Drag to rotate the globe.',
            'Orbit|Showing %{shown} of %{total} items. Drag to rotate the globe.',
            this.totalIndexedNodes,
          ),
          {
            shown: formatNumber(Math.min(this.displayedNodeCount, this.totalIndexedNodes)),
            total: formatNumber(this.totalIndexedNodes),
          },
        );
      }

      return sprintf(
        n__(
          'Orbit|Showing %{shown} item. Drag to rotate the globe.',
          'Orbit|Showing %{shown} items. Drag to rotate the globe.',
          this.displayedNodeCount,
        ),
        { shown: formatNumber(this.displayedNodeCount) },
      );
    },
    entityItemsLine() {
      const { entityType: entity } = this.instanceMapRequest;

      if (this.totalIndexedNodes > 0) {
        return sprintf(
          n__(
            'Orbit|Showing %{shown} of %{total} %{entity} item. Drag to rotate the globe.',
            'Orbit|Showing %{shown} of %{total} %{entity} items. Drag to rotate the globe.',
            this.totalIndexedNodes,
          ),
          {
            shown: formatNumber(Math.min(this.displayedNodeCount, this.totalIndexedNodes)),
            total: formatNumber(this.totalIndexedNodes),
            entity,
          },
        );
      }

      return sprintf(
        n__(
          'Orbit|Showing %{shown} %{entity} item. Drag to rotate the globe.',
          'Orbit|Showing %{shown} %{entity} items. Drag to rotate the globe.',
          this.displayedNodeCount,
        ),
        { shown: formatNumber(this.displayedNodeCount), entity },
      );
    },
    groupsLine() {
      if (this.enabledGroupsCount <= this.enabledMemberGroups.length) return '';

      return sprintf(s__('Orbit|Only the first %{shown} of %{total} groups are shown.'), {
        shown: formatNumber(this.enabledMemberGroups.length),
        total: formatNumber(this.enabledGroupsCount),
      });
    },
  },
  watch: {
    indexingProgress: 'loadStats',
    initialGroupNodesKey() {
      this.globeNodes = this.initialGroupNodes;
    },
  },
  created() {
    this.globeNodes = this.initialGroupNodes;
    this.loadStats();
  },
  async mounted() {
    try {
      const { data } = await fetchOrbitSchema({ expand: '*' });
      this.schema = data;
    } catch (error) {
      if (orbitErrorKind(error) === ORBIT_ERROR_KIND.SERVER) Sentry.captureException(error);
    }
  },
  methods: {
    async loadStats() {
      if (this.anyIndexing) return;

      this.statsRequestId += 1;
      const requestId = this.statsRequestId;
      if (!this.graphStats) this.statsStatus = LOAD_STATUS.LOADING;
      try {
        const stats = await fetchCombinedGraphStats(this.enabledMemberGroups, { strict: true });
        if (requestId !== this.statsRequestId) return;
        this.graphStats = stats;
        this.statsStatus = LOAD_STATUS.READY;
      } catch (error) {
        if (requestId !== this.statsRequestId) return;
        const kind = orbitErrorKind(error);
        if (kind === ORBIT_ERROR_KIND.SERVER) Sentry.captureException(error);
        this.graphStats = null;
        this.statsStatus =
          kind === ORBIT_ERROR_KIND.FORBIDDEN ? LOAD_STATUS.FORBIDDEN : LOAD_STATUS.FAILED;
      }
    },
  },
  emptyEdges: EMPTY_EDGES,
});
</script>

<template>
  <div class="gl-flex gl-flex-col gl-gap-3 gl-pt-5" data-testid="orbit-overview-page">
    <div class="gl-relative">
      <overview-stats-card
        v-if="!anyIndexing"
        class="gl-mb-3 md:gl-absolute md:gl-left-4 md:gl-top-4 md:gl-z-2 md:gl-mb-0 md:gl-w-full md:gl-max-w-28"
        :group-count="enabledMemberGroups.length"
        :graph-stats="graphStats"
        :status="statsStatus"
      />

      <div class="gl-relative gl-h-62 gl-overflow-hidden gl-rounded-lg">
        <graph-explorer
          :key="instanceMapRequest ? instanceMapRequest.entityType : 'groups'"
          :initial-nodes="globeNodes"
          :initial-edges="$options.emptyEdges"
          :schema="schema"
          :instance-map-request="instanceMapRequest"
          :neighbors-version="indexingProgress"
          :expand-neighbors="!defaultGroupMissing"
          @node-counts-change="displayedCounts = $event"
          @map-unavailable="mapUnavailable = true"
        />

        <div
          v-if="anyIndexing"
          class="gl-absolute gl-inset-0 gl-z-2 gl-flex gl-items-center gl-justify-center gl-bg-overlay gl-p-4"
          role="status"
          data-testid="overview-indexing-overlay"
        >
          <div
            class="gl-flex gl-items-center gl-gap-3 gl-rounded-lg gl-bg-default gl-px-4 gl-py-3 gl-shadow-sm"
          >
            <gl-loading-icon size="sm" inline :label="s__('Orbit|Indexing')" />
            <span>
              {{ s__('Orbit|Indexing in progress. The map fills in as data finishes indexing.') }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <p
      v-if="!mapUnavailable"
      class="gl-mb-0 gl-text-sm gl-text-subtle"
      aria-live="polite"
      data-testid="overview-status-line"
    >
      {{ statusLine }}
    </p>
  </div>
</template>
