<script>
import { defineComponent } from 'vue';
import { n__ } from '~/locale';
import { CENTER_DOMAIN_KEY, DOMAIN_RING_RADIUS } from './constants';
import { VIEWBOX_CENTER, placementStyle, ringPositions } from './schema_graph';
import SchemaEntityIcon from './schema_entity_icon.vue';

export default defineComponent({
  name: 'SchemaDomainMap',
  compatConfig: { MODE: 3 },
  components: { SchemaEntityIcon },
  props: {
    domains: {
      type: Array,
      required: true,
    },
  },
  emits: ['select'],
  computed: {
    centerDomain() {
      return this.domains.find((domain) => domain.key === CENTER_DOMAIN_KEY) || null;
    },
    ringDomains() {
      const others = this.domains.filter((domain) => domain !== this.centerDomain);
      const positions = ringPositions(others.length, DOMAIN_RING_RADIUS);
      return others.map((domain, index) => ({
        ...domain,
        position: positions[index],
        iconSize: 'lg',
        subtitle: n__('Orbit|%d entity', 'Orbit|%d entities', domain.entities.length),
      }));
    },
    nodes() {
      if (!this.centerDomain) return this.ringDomains;

      const center = {
        ...this.centerDomain,
        position: { x: VIEWBOX_CENTER, y: VIEWBOX_CENTER },
        iconSize: 'xl',
        subtitle: this.centerDomain.entities.map((entity) => entity.name).join(', '),
      };
      return [center, ...this.ringDomains];
    },
  },
  methods: {
    placementStyle,
  },
  VIEWBOX_CENTER,
});
</script>

<template>
  <div
    class="gl-border gl-relative gl-h-80 gl-overflow-hidden gl-rounded-lg gl-border-default gl-bg-subtle"
    data-testid="schema-domain-map"
  >
    <svg
      class="gl-absolute gl-left-0 gl-top-0 gl-h-full gl-w-full"
      viewBox="0 0 100 100"
      preserveAspectRatio="none"
      aria-hidden="true"
    >
      <line
        v-for="domain in ringDomains"
        :key="domain.key"
        :x1="$options.VIEWBOX_CENTER"
        :y1="$options.VIEWBOX_CENTER"
        :x2="domain.position.x"
        :y2="domain.position.y"
        style="stroke: var(--gl-border-color-default)"
        stroke-width="2"
        vector-effect="non-scaling-stroke"
      />
    </svg>

    <button
      v-for="domain in nodes"
      :key="domain.key"
      type="button"
      class="gl-absolute gl-flex -gl-translate-x-1/2 -gl-translate-y-1/2 gl-flex-col gl-items-center gl-gap-2 gl-border-0 gl-bg-transparent gl-p-2 focus-visible:gl-focus"
      :style="placementStyle(domain.position)"
      data-testid="schema-domain"
      @click="$emit('select', domain.entryEntity)"
    >
      <schema-entity-icon :icon="domain.icon" :color="domain.color" :size="domain.iconSize" />
      <span class="gl-font-bold">{{ domain.label }}</span>
      <span class="gl-text-sm gl-text-subtle">{{ domain.subtitle }}</span>
    </button>
  </div>
</template>
