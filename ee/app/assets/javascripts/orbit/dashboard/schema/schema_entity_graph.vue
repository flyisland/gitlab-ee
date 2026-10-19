<script>
import { defineComponent } from 'vue';
import { GlTooltipDirective } from '@gitlab/ui';
import { n__, sprintf } from '~/locale';
import { MAX_LABELED_NEIGHBORS, NEIGHBOR_RING_RADIUS } from './constants';
import { VIEWBOX_CENTER, placementStyle, ringPositions, scaleFromCenter } from './schema_graph';
import SchemaEntityIcon from './schema_entity_icon.vue';

const EDGE_LABEL_DISTANCE = 0.55;

export default defineComponent({
  name: 'SchemaEntityGraph',
  compatConfig: { MODE: 3 },
  components: { SchemaEntityIcon },
  directives: { GlTooltip: GlTooltipDirective },
  props: {
    entity: {
      type: Object,
      required: true,
    },
    neighbors: {
      type: Array,
      required: true,
    },
  },
  emits: ['select'],
  VIEWBOX_CENTER,
  computed: {
    showEdgeLabels() {
      return this.neighbors.length <= MAX_LABELED_NEIGHBORS;
    },
    ring() {
      const positions = ringPositions(this.neighbors.length, NEIGHBOR_RING_RADIUS, {
        alternate: !this.showEdgeLabels,
      });
      return this.neighbors.map((neighbor, index) => ({
        ...neighbor,
        position: positions[index],
        labelPosition: scaleFromCenter(positions[index], EDGE_LABEL_DISTANCE),
      }));
    },
    caption() {
      return sprintf(
        n__(
          'Orbit|%{entity} connects to %{count} entity. Select it to move to it.',
          'Orbit|%{entity} connects to %{count} entities. Select one to move to it.',
          this.neighbors.length,
        ),
        { entity: this.entity.name, count: this.neighbors.length },
      );
    },
  },
  methods: {
    placementStyle,
    edgeLabel(neighbor) {
      const [first, ...rest] = neighbor.edges;
      if (!rest.length) return first.name;

      return sprintf(
        n__('Orbit|%{name} +%{count} more', 'Orbit|%{name} +%{count} more', rest.length),
        {
          name: first.name,
          count: rest.length,
        },
      );
    },
    edgeNames(neighbor) {
      return neighbor.edges.map((edge) => edge.name).join(', ');
    },
  },
});
</script>

<template>
  <div class="gl-flex gl-flex-col gl-gap-2" data-testid="schema-entity-graph">
    <div
      class="gl-border gl-relative gl-h-80 gl-overflow-hidden gl-rounded-lg gl-border-default gl-bg-subtle"
    >
      <svg
        class="gl-absolute gl-left-0 gl-top-0 gl-h-full gl-w-full"
        viewBox="0 0 100 100"
        preserveAspectRatio="none"
        aria-hidden="true"
      >
        <line
          v-for="neighbor in ring"
          :key="neighbor.name"
          :x1="$options.VIEWBOX_CENTER"
          :y1="$options.VIEWBOX_CENTER"
          :x2="neighbor.position.x"
          :y2="neighbor.position.y"
          style="stroke: var(--gl-border-color-strong)"
          stroke-width="1.5"
          vector-effect="non-scaling-stroke"
        />
      </svg>

      <template v-if="showEdgeLabels">
        <span
          v-for="neighbor in ring"
          :key="`label-${neighbor.name}`"
          class="gl-absolute -gl-translate-x-1/2 -gl-translate-y-1/2 gl-whitespace-nowrap gl-bg-subtle gl-px-1 gl-font-monospace gl-text-xs gl-text-subtle"
          :style="placementStyle(neighbor.labelPosition)"
          data-testid="schema-edge-label"
        >
          {{ edgeLabel(neighbor) }}
        </span>
      </template>

      <div
        class="gl-pointer-events-none gl-absolute gl-left-1/2 gl-top-1/2 gl-flex -gl-translate-x-1/2 -gl-translate-y-1/2 gl-flex-col gl-items-center gl-gap-2"
      >
        <schema-entity-icon :icon="entity.icon" :color="entity.color" size="xl" />
        <span class="gl-bg-subtle gl-px-1 gl-font-bold">{{ entity.name }}</span>
      </div>

      <button
        v-for="neighbor in ring"
        :key="`node-${neighbor.name}`"
        v-gl-tooltip
        type="button"
        class="gl-absolute gl-flex -gl-translate-x-1/2 -gl-translate-y-1/2 gl-flex-col gl-items-center gl-gap-1 gl-border-0 gl-bg-transparent gl-p-1 focus-visible:gl-focus"
        :style="placementStyle(neighbor.position)"
        :title="edgeNames(neighbor)"
        data-testid="schema-neighbor"
        @click="$emit('select', neighbor.name)"
      >
        <schema-entity-icon :icon="neighbor.icon" :color="neighbor.color" size="md" />
        <span class="gl-whitespace-nowrap gl-bg-subtle gl-px-1 gl-text-xs gl-font-bold">
          {{ neighbor.name }}
        </span>
      </button>
    </div>
    <p class="gl-mb-0 gl-text-sm gl-text-subtle">{{ caption }}</p>
  </div>
</template>
