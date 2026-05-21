<script>
import { defineComponent } from 'vue';
import { GlBadge } from '@gitlab/ui';
import { n__, s__, sprintf } from '~/locale';

const COLLAPSED_COUNT = 5;

export default defineComponent({
  name: 'GraphLegend',
  compatConfig: { MODE: 3 },
  components: {
    GlBadge,
  },
  i18n: {
    showLess: s__('Orbit|Show less'),
  },
  props: {
    items: {
      type: Array,
      required: false,
      default: () => [],
    },
    activeTypeFilters: {
      type: Set,
      required: false,
      default: () => new Set(),
    },
    isCompact: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  emits: ['select-type'],
  data() {
    return {
      expanded: false,
    };
  },
  computed: {
    sortedItems() {
      return [...this.items].sort((a, b) => {
        const ca = a.count ?? 0;
        const cb = b.count ?? 0;
        if (cb !== ca) return cb - ca;
        return a.name.localeCompare(b.name);
      });
    },
    visibleItems() {
      if (!this.isCompact || this.expanded) return this.sortedItems;
      return this.sortedItems.slice(0, COLLAPSED_COUNT);
    },
    hiddenCount() {
      if (!this.isCompact || this.expanded) return 0;
      return Math.max(0, this.sortedItems.length - COLLAPSED_COUNT);
    },
    hasOverflow() {
      return this.isCompact && this.sortedItems.length > COLLAPSED_COUNT;
    },
    moreLabel() {
      return sprintf(n__('Orbit|+%{count} more', 'Orbit|+%{count} more', this.hiddenCount), {
        count: this.hiddenCount,
      });
    },
  },
  methods: {
    isActive(type) {
      return this.activeTypeFilters.size === 0 || this.activeTypeFilters.has(type);
    },
  },
});
</script>

<template>
  <div v-if="items.length" class="gl-flex gl-flex-col gl-gap-0" data-testid="graph-legend">
    <button
      v-for="item in visibleItems"
      :key="item.type"
      type="button"
      class="gl-flex gl-cursor-pointer gl-items-center gl-gap-2 gl-rounded-base gl-border-0 gl-bg-transparent gl-px-1 gl-py-0 gl-shadow-none hover:gl-bg-strong"
      :class="isActive(item.type) ? '' : 'gl-opacity-3'"
      :title="item.name"
      :aria-pressed="String(isActive(item.type))"
      data-testid="legend-item"
      @click="$emit('select-type', item.type)"
    >
      <span class="gl-flex gl-w-20 gl-min-w-0 gl-shrink-0 gl-items-center gl-gap-2">
        <span
          class="gl-inline-block gl-h-2 gl-w-2 gl-flex-shrink-0 gl-rounded-full"
          :style="{ backgroundColor: item.color }"
        ></span>
        <span class="gl-truncate gl-text-left gl-text-sm">{{ item.name }}</span>
      </span>
      <span class="gl-w-8 gl-shrink-0 gl-text-right">
        <gl-badge v-if="item.count != null && item.count > 0" size="sm" variant="neutral">
          {{ item.count }}
        </gl-badge>
      </span>
    </button>
    <button
      v-if="hasOverflow"
      type="button"
      class="gl-mt-1 gl-cursor-pointer gl-border-0 gl-bg-transparent gl-p-0 gl-text-sm gl-text-link"
      data-testid="toggle-legend-btn"
      @click="expanded = !expanded"
    >
      <template v-if="expanded">{{ $options.i18n.showLess }}</template>
      <template v-else>{{ moreLabel }}</template>
    </button>
  </div>
</template>
